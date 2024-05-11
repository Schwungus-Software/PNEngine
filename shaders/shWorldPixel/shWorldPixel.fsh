/* -----------------------
   SMF FRAGMENT ÜBERSHADER
       (PER-FRAGMENT)
    Original by TheSnidr
          Forked by
    Can't Sleep & nonk123
        for PNEngine
   ----------------------- */

#define LIGHT_SIZE 12
#define MAX_LIGHTS 16
#define MAX_LIGHT_DATA 192

/* --------
   VARYINGS
   -------- */

varying vec2 v_texcoord;
varying vec4 v_color;
varying vec3 v_object_space_position;
varying vec3 v_world_normal;
varying vec3 v_reflection;
varying float v_fog_distance;
varying vec4 v_shadowmap;

/* --------
   UNIFORMS
   -------- */

uniform vec4 u_uvs;

uniform vec4 u_color;

uniform vec4 u_fog_color;

uniform vec4 u_material_color;
uniform float u_material_alpha_test;

uniform int u_material_can_blend;
uniform sampler2D u_material_blend;
uniform vec4 u_material_blend_uvs;

uniform float u_material_bright;
uniform vec2 u_material_specular; // base, exponent

uniform vec4 u_ambient_color;
uniform vec2 u_fog_distance;
uniform float u_light_data[MAX_LIGHT_DATA];

uniform int u_shadowmap_enable_pixel;
uniform sampler2D u_shadowmap;
uniform int u_shadowmap_caster;
uniform mat4 u_shadowmap_projection;

// https://github.com/XorDev/GM_Shadows/blob/main/GM_Shadows/shaders/shd_light/shd_light.fsh
float shadow_hard(vec4 p) {
	// Project shadow map UVs
	vec2 uv = p.xy / p.w * vec2(0.5, -0.5) + 0.5;
	
	// Difference in shadow map and current depth
	float dif = (texture2D(u_shadowmap, uv).r - p.z) / p.w;
	
	// Map to the 0 to 1 range
	return clamp(dif * 2e3 + 2., 0., 1.);
}

void main() {
	// Lighting
	vec4 total_light = u_ambient_color;
	float total_specular = 0.;
	
	for (int i = 0; i < MAX_LIGHT_DATA; i += LIGHT_SIZE) {
		if (bool(u_light_data[i + 1])) {
			int light_type = int(u_light_data[i]);
		
			if (light_type == 1) { // Directional
				vec3 light_normal = vec3(-u_light_data[i + 5], -u_light_data[i + 6], -u_light_data[i + 7]);
				vec4 light_color = vec4(u_light_data[i + 8], u_light_data[i + 9], u_light_data[i + 10], u_light_data[i + 11]);
				float factor;
				
				if (bool(u_shadowmap_enable_pixel) && u_shadowmap_caster == i) {
					// Compute shadow-projection-space coordinates
					vec4 proj = u_shadowmap_projection * v_shadowmap;
					
					// Normalize to the -1 to +1 range (accounting for perspective)
					vec2 suv = proj.xy / proj.w;
					
					// Edge vignette from shadow uvs
					vec2 edge = max(1. - suv * suv, 0.);
					
					// Shade anything outside of the shadow map
					factor = (edge.x * edge.y * float(proj.z > 0.));
					
					// Only do shadow mapping inside the shadow map
					if (factor > 0.01) {
						factor *= shadow_hard(proj);
					}
				} else {
					factor = 1.;
				}
				
				total_light += max(dot(v_world_normal, light_normal), 0.) * light_color * factor;
				total_specular += max(dot(v_reflection, light_normal), 0.) * factor;
			} else if (light_type == 2) { // Point
				// Get light information
				vec3 light_position = vec3(u_light_data[i + 2], u_light_data[i + 3], u_light_data[i + 4]);
				float light_start = u_light_data[i + 5];
				float light_end = u_light_data[i + 6];
				vec4 light_color = vec4(u_light_data[i + 8], u_light_data[i + 9], u_light_data[i + 10], u_light_data[i + 11]);
				
				// Calculate lighting
				vec3 light_direction = normalize(v_object_space_position - light_position);
				float attenuation = max((light_end - distance(v_object_space_position, light_position)) / (light_end - light_start), 0.);
				float angle_difference = max(dot(v_world_normal, -light_direction), 0.);
				
				// Add to total lighting
				total_light += attenuation * light_color * angle_difference;
				total_specular += attenuation * max(dot(v_reflection, light_direction), 0.);
			}
		}
	}
	
	total_light = vec4(mix(total_light.rgb, vec3(1.), u_material_bright), min(total_light.a, 1.));
	total_specular = mix(u_material_specular.x * total_specular, 0., u_material_bright);
	
	// Fog
	float fog_start = u_fog_distance.x;
	float fog = clamp((v_fog_distance - fog_start) / (u_fog_distance.y - fog_start), 0., 1.);
	
	// Final changes
	float u = fract(v_texcoord.x);
	float v = fract(v_texcoord.y);
	vec2 uv = vec2(u_uvs.r + (u_uvs.b * u), u_uvs.g + (u_uvs.a * v));
	vec4 sample = texture2D(gm_BaseTexture, uv);
	float v_alpha;
	
	if (bool(u_material_can_blend)) {
		vec2 blend_uv = vec2(u_material_blend_uvs.r + (u_material_blend_uvs.b * u), u_material_blend_uvs.g + (u_material_blend_uvs.a * v));
		
		sample = mix(texture2D(u_material_blend, blend_uv), sample, v_color.a);
		v_alpha = 1.;
	} else {
		v_alpha = v_color.a;
	}
	
	if (u_material_alpha_test > 0.) {
		if (sample.a < u_material_alpha_test) {
			discard;
		}
		
		sample.a = 1.;
	}
	
	vec4 starting_color = (sample * u_material_color * vec4(v_color.rgb, v_alpha) * total_light) + pow(total_specular, u_material_specular.y);
	
	starting_color.rgb = mix(starting_color.rgb, u_fog_color.rgb, fog);
	starting_color.a *= mix(1., u_fog_color.a, fog);
	gl_FragColor = starting_color * u_color;
	
	const mat4 pattern = mat4(
		vec4(0.0625, 0.5625, 0.1875, 0.6875),
		vec4(0.8125, 0.3125, 0.9375, 0.4375),
		vec4(0.25, 0.75, 0.125, 0.625),
		vec4(1.0, 0.5, 0.875, 0.375)
	);
    
	if (gl_FragColor.a < pattern[int(mod(gl_FragCoord.x, 4.))][int(mod(gl_FragCoord.y, 4.))]) {
		discard;
	}
	
	gl_FragColor.a = 1.;
}