// Bloom pass fragment shader

varying vec2 v_texcoord;

uniform float u_threshold;
uniform float u_intensity;

void main() {
    vec4 c = texture2D(gm_BaseTexture, v_texcoord);
    float bright = 0.21 * c.r + 0.71 * c.g + 0.07 * c.b;
	
	c.rgb *= step(u_threshold, bright) * u_intensity;
    gl_FragColor = c;
}