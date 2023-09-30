function Submodel() : Asset() constructor {
	vbo = undefined
	materials = []
	hidden = false
	
	static destroy = function () {
		vertex_delete_buffer(vbo)
	}
}