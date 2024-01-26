varying vec2 v_texcoord;

uniform vec2 u_texel;

void main() {
	float u = u_texel.x;
	float v = u_texel.y;
	
    gl_FragColor = (texture2D(gm_BaseTexture, v_texcoord + vec2(2. * u, 0.))
					+ texture2D(gm_BaseTexture, v_texcoord + vec2(-2. * u, 0.))
					+ texture2D(gm_BaseTexture, v_texcoord + vec2(0., 2. * v))
					+ texture2D(gm_BaseTexture, v_texcoord + vec2(0., -2. * v))
					+ 2. * texture2D(gm_BaseTexture, v_texcoord + vec2(u, v))
					+ 2. * texture2D(gm_BaseTexture, v_texcoord + vec2(-u, v))
					+ 2. * texture2D(gm_BaseTexture, v_texcoord + vec2(u, -v))
					+ 2. * texture2D(gm_BaseTexture, v_texcoord + vec2(-u, -v))) * 0.0833333333333333;
}