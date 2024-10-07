// Simple passthrough vertex shader
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_texcoord;
varying vec4 v_color;
varying vec2 v_fragcoord;

void main() {
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, in_Position.z, 1.);
	v_color = in_Colour;
	v_texcoord = in_TextureCoord;
	v_fragcoord = in_Position.xy;
}