/// @desc Adds a vertex to the specified vertex buffer.
function vbo_add_vertex(_vbo, _x, _y, _z, _nx, _ny, _nz, _u, _v, _color, _alpha, _color2 = c_white, _alpha2 = 1, _color3 = c_white, _alpha3 = 1) {
	gml_pragma("forceinline")
	
	vertex_position_3d(_vbo, _x, _y, _z)
	vertex_normal(_vbo, _nx, _ny, _nz)
	vertex_texcoord(_vbo, _u, _v)
	vertex_color(_vbo, _color, _alpha)
	vertex_color(_vbo, _color2, _alpha2)
	vertex_color(_vbo, _color3, _alpha3)
}