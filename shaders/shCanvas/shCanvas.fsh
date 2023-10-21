// Simple passthrough fragment shader
varying vec2 v_texcoord;
varying vec4 v_color;

void main() {
    vec4 color = v_color * texture2D(gm_BaseTexture, v_texcoord);
	
	gl_FragColor = vec4(color.rgb * color.a, color.a);
}
