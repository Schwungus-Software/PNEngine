/* -----------------------
   SMF FRAGMENT ÜBERSHADER
        (PER-VERTEX)
    Original by TheSnidr
          Forked by
    Can't Sleep & nonk123
        for PNEngine
   ----------------------- */

/* --------
   VARYINGS
   -------- */

varying vec2 v_texcoord;
varying vec2 v_texcoord2;
varying vec4 v_color;
varying vec4 v_lighting;
varying vec2 v_specular;
varying vec2 v_rimlight;
varying float v_fog;

/* --------
   UNIFORMS
   -------- */

uniform vec4 u_uvs;

uniform vec4 u_color;
uniform vec4 u_stencil;

uniform vec4 u_fog_color;

uniform vec4 u_material_color;
uniform float u_material_alpha_test;

uniform int u_material_can_blend;
uniform sampler2D u_material_blend;
uniform vec4 u_material_blend_uvs;

uniform int u_lightmap_enable_pixel;
uniform sampler2D u_lightmap;
uniform vec4 u_lightmap_uvs;

void main() {
	float u = fract(v_texcoord.x);
	float v = fract(v_texcoord.y);
	vec2 uv = vec2(u_uvs.r + (u_uvs.b * u), u_uvs.g + (u_uvs.a * v));
	vec4 sample = texture2D(gm_BaseTexture, uv);
	float v_alpha;
	
	if (u_material_can_blend == 1) {
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
	
	vec4 lighting = v_lighting;
	
	if (bool(u_lightmap_enable_pixel)) {
		float lu = fract(v_texcoord2.x);
		float lv = fract(v_texcoord2.y);
		vec2 lightmap_uv = vec2(u_lightmap_uvs.r + (u_lightmap_uvs.b * lu), u_lightmap_uvs.g + (u_lightmap_uvs.a * lv));
		
		lighting += texture2D(u_lightmap, lightmap_uv);
	}
	
	vec4 starting_color = sample * u_material_color * vec4(v_color.rgb, v_alpha) * lighting;
	
	starting_color.rgb += pow(v_specular.x, v_specular.y) + pow(v_rimlight.x, v_rimlight.y);
	starting_color.rgb = mix(starting_color.rgb, u_fog_color.rgb, v_fog);
	starting_color.a *= mix(1., u_fog_color.a, v_fog);
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
	gl_FragColor.rgb = mix(gl_FragColor.rgb, u_stencil.rgb, u_stencil.a);
}