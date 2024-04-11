//
// Simple passthrough fragment shader
//
varying vec2 v_texcoord;
varying vec4 v_color;

void main() {
    gl_FragColor = v_color * texture2D(gm_BaseTexture, v_texcoord);
}
