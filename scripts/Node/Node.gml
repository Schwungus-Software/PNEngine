function Node() constructor {
	index = 0
	name = ""
	parent = undefined
	children = []
	is_bone = false
	dq = dq_build_identity()
	
	static from_buffer = function (_buffer) {
		name = buffer_read(_buffer, buffer_string)
		index = buffer_read(_buffer, buffer_f32)
		is_bone = buffer_read(_buffer, buffer_bool)
		
		var i = 0
		
		repeat 8 {
			dq[i++] = buffer_read(_buffer, buffer_f32)
		}
		
		// Meshes
		var _mesh_count = buffer_read(_buffer, buffer_u32)
		
		repeat _mesh_count {
			buffer_read(_buffer, buffer_u32)
		}
		
		// Children
		var _child_count = buffer_read(_buffer, buffer_u32)
		
		array_resize(children, _child_count)
		i = 0

		repeat _child_count {
			var _child = new Node()
			
			_child.parent = self
			children[i++] = _child
			_child.from_buffer(_buffer)
		}
		
		return self
	}
}