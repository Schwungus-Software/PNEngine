function Model() : Asset() constructor {
	submodels = []
	collider = undefined
	
	head_bone = -1
	torso_bone = -1
	hold_bone = -1
	
	hold_offset_matrix = undefined
	
	static destroy = function () {
		destroy_array(submodels)
		
		if collider != undefined {
			collider.destroy()
		}
	}
}