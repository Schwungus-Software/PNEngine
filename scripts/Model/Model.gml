function Model() : Asset() constructor {
	submodels = []
	collider = undefined
	animations = []
	
	head_bone = -1
	torso_bone = -1
	hold_bone = -1
	
	hold_offset_x = 0
	hold_offset_y = 0
	hold_offset_z = 0
	
	static destroy = function () {
		destroy_array(submodels)
		
		if collider != undefined {
			collider.destroy()
		}
		
		destroy_array(animations)
	}
}