/* -----------------
   SKY VERTEX SHADER
   ----------------- */

/* ----------
   ATTRIBUTES
   ---------- */

attribute vec3 in_Position; // (x, y, z) 
attribute vec3 in_Normal; // (x, y, z)
attribute vec2 in_TextureCoord; // (u, v)
attribute vec2 in_TextureCoord2; // (u, v)
attribute vec4 in_Colour; // (r, g, b, a)
attribute vec4 in_BoneIndex; // (bone 1, bone 2, bone 3, bone 4)
attribute vec4 in_BoneWeight; // (weight 1, weight 2, weight 3, weight 4)

/* --------
   VARYINGS
   -------- */

varying vec2 v_texcoord;
varying vec4 v_color;

/* --------
   UNIFORMS
   -------- */

uniform float u_time;

uniform vec2 u_material_scroll;

void main() {
	vec4 object_space_position = vec4(in_Position, 1.);

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_position;
	v_color = in_Colour;
	v_texcoord = in_TextureCoord + (u_time * u_material_scroll);
}