varying vec2 v_texcoord;

uniform vec2 u_texel;

void main() {
	float u = u_texel.x;
	float v = u_texel.y;
	
	gl_FragColor = (4. * texture2D(gm_BaseTexture, v_texcoord)
					+ texture2D(gm_BaseTexture, v_texcoord + vec2(u, 0.))
					+ texture2D(gm_BaseTexture, v_texcoord + vec2(-u, 0.))
					+ texture2D(gm_BaseTexture, v_texcoord + vec2(0., v))
					+ texture2D(gm_BaseTexture, v_texcoord + vec2(0., -v))) * 0.125;
}