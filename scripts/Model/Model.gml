function Model() : Asset() constructor {
	submodels = undefined
	submodels_amount = 0
	
	root_node = undefined
	
	collider = undefined
	
	bone_offsets = undefined
	head_bone = -1
	torso_bone = -1
	hold_bone = -1
	hold_offset_matrix = undefined
	points = undefined
	
	static destroy = function () {
		destroy_array(submodels)
		
		if collider != undefined {
			collider.destroy()
		}
	}
}