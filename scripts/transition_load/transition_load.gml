/// @func transition_load(index)
function transition_load(_type) {
	if is_string(_type) {
		var _script = global.scripts.fetch(_type)
		
		if _script != undefined and is_instanceof(_script, TransitionScript) {
			return true
		}
		
		return transition_load(asset_get_index(_type))
	}
	
	if object_exists(_type) {
		with instance_create_depth(0, 0, 0, _type) {
			event_user(ThingEvents.LOAD)
			instance_destroy(id, false)
		}
		
		return true
	}
	
	return false
}