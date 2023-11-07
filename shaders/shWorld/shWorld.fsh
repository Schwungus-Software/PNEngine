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

void main() {
	vec2 uv = vec2(u_uvs.r + (u_uvs.b * fract(v_texcoord.x)), u_uvs.g + (u_uvs.a * fract(v_texcoord.y)));
	vec4 sample = texture2D(gm_BaseTexture, uv);
	
	if (u_material_alpha_test > 0.) {
		if (sample.a < u_material_alpha_test) {
			discard;
		}
		
		sample.a = 1.;
	}
	
	vec4 starting_color = sample * u_material_color * v_color * v_lighting;
	
	starting_color.rgb = mix(starting_color.rgb, u_fog_color.rgb, v_fog) + pow(v_specular.x, v_specular.y);
	starting_color.a *= mix(1.0, u_fog_color.a, v_fog);
    gl_FragColor = starting_color * u_color;
	
	// Screen-door transparency
	/*mat4 pattern = mat4(
		vec4(0.0588235294117647, 0.5294117647058824, 0.1764705882352941, 0.6470588235294118),
		vec4(0.7647058823529412, 0.2941176470588235, 0.8823529411764706, 0.4117647058823529),
		vec4(0.2352941176470588, 0.7058823529411765, 0.1176470588235294, 0.5882352941176471),
		vec4(0.9411764705882353, 0.4705882352941176, 0.8235294117647059, 0.3529411764705882)
	);
    
	if (gl_FragColor.a < pattern[int(mod(gl_FragCoord.x, 4.))][int(mod(gl_FragCoord.y, 4.))]) {
		discard;
	}
	
	gl_FragColor.a = 1.;*/
}