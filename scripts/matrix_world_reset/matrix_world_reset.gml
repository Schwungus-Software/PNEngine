// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function matrix_world_reset() {
	gml_pragma("forceinline")
	
	static _default = matrix_build_identity()
	
	matrix_set(matrix_world, _default)
}