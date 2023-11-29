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
varying vec4 v_color;
varying float v_light_depth;

/* --------
   UNIFORMS
   -------- */

uniform vec4 u_uvs;

uniform vec4 u_color;

uniform vec4 u_material_color;
uniform float u_material_alpha_test;
uniform float u_material_bright;

uniform int u_material_can_blend;
uniform sampler2D u_material_blend;
uniform vec4 u_material_blend_uvs;

/* ---------
   CONSTANTS
   --------- */

const float SCALE_FACTOR = 16777215.;

vec3 toDepthColor(float depth) {
	float intf = depth * SCALE_FACTOR;
	
	return floor(vec3(mod(intf, 256.), mod(intf / 256., 256.), intf / 65536.)) / 255.;
}

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
	
	gl_FragColor = (sample * u_material_color * vec4(v_color.rgb, mix(v_alpha, 0., u_material_bright))) * u_color;
	
	// Use screen-door transparnecy for the depth shader. This allows us to
	// have the effect of having more transparent shadows.
	mat4 pattern = mat4(
		vec4(0.0588235294117647, 0.5294117647058824, 0.1764705882352941, 0.6470588235294118),
		vec4(0.7647058823529412, 0.2941176470588235, 0.8823529411764706, 0.4117647058823529),
		vec4(0.2352941176470588, 0.7058823529411765, 0.1176470588235294, 0.5882352941176471),
		vec4(0.9411764705882353, 0.4705882352941176, 0.8235294117647059, 0.3529411764705882)
	);
    
	if (gl_FragColor.a < pattern[int(mod(gl_FragCoord.x, 4.))][int(mod(gl_FragCoord.y, 4.))]) {
		discard;
	}
	
	gl_FragColor = vec4(toDepthColor(v_light_depth), 1);
}