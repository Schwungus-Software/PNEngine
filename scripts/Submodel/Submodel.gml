function Submodel() : Asset() constructor {
	vbo = undefined
	materials = []
	material_index = 0
	hidden = false
	
	static destroy = function () {
		vertex_delete_buffer(vbo)
	}
}