event_inherited()

if instance_exists(shadow_camera) {
	instance_destroy(shadow_camera)
}

// Iterate through area lights to find the next shadowmap caster
with area {
	if shadowmap_caster == other.id {
		shadowmap_caster = noone
		
		var i = 0
		
		repeat ds_list_size(lights) {
			var _light = lights[| i++]
			
			if instance_exists(_light) and _light.is_ancestor(DirectionalLight) and _light.shadow {
				shadowmap_caster = _light
				
				break
			}
		}
	}
}