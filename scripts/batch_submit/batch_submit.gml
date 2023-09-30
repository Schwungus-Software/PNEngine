/// @desc Submits the current batch, creating a new one.
function batch_submit() {
	var _batch_texture = global.batch_texture
	
	if _batch_texture == undefined {
		// Abort if the batch is completely empty
		return false
	}
	
	with global.current_shader {
		set_uniform("u_animated", 0)
		set_uniform("u_color", 1, 1, 1, 1)
		set_uniform("u_material_bright", global.batch_bright)
		set_uniform("u_material_color", 1, 1, 1, 1)
		set_uniform("u_material_scroll", 0, 0)
		set_uniform("u_material_specular", 0, 1)
		set_uniform("u_material_wind", 0, 1, 1)
		set_uniform("u_uvs", 0, 0, 1, 1)
	}
	
	var _matrix = matrix_get(matrix_world)
	var _blend_mode = gpu_get_blendmode()
	var _batch_vbo = global.batch_vbo
	
	matrix_world_reset()
	gpu_set_blendmode(global.batch_blendmode)
	vertex_end(_batch_vbo)
	vertex_submit(_batch_vbo, pr_trianglelist, _batch_texture)
	gpu_set_blendmode(_blend_mode)
	matrix_set(matrix_world, _matrix)
	
	vertex_delete_buffer(_batch_vbo)
	_batch_vbo = vertex_create_buffer()
	vertex_begin(_batch_vbo, global.vbo_format)
	global.batch_vbo = _batch_vbo
	global.batch_texture = undefined
	
	return true
}