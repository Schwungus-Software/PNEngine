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
varying vec4 v_lighting;
varying vec2 v_specular;
varying float v_fog;

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
	
	vec4 starting_color = sample * u_material_color * vec4(v_color.rgb, v_alpha) * v_lighting;
	
	starting_color.rgb = mix(starting_color.rgb, u_fog_color.rgb, v_fog) + pow(v_specular.x, v_specular.y);
	starting_color.a *= mix(1., u_fog_color.a, v_fog);
    gl_FragColor = starting_color * u_color;
}