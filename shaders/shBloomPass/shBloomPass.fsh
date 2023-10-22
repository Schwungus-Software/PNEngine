// Bloom pass fragment shader

varying vec2 v_texcoord;

const float threshold = 0.885;
const float intensity = 0.09;

void main() {
    vec4 c = texture2D(gm_BaseTexture, v_texcoord);
    float bright = 0.21 * c.r + 0.71 * c.g + 0.07 * c.b;
	
	c.rgb *= step(threshold, bright) * intensity;
    gl_FragColor = c;
}