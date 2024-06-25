/// @func transition_load(type)
/// @desc Loads a type of Transition for use in the current level.
/// @param {Asset.GMObject or string} type The type of Transition to load.
function transition_load(_type) {
	if is_string(_type) {
		var _scripts = global.scripts
		
		_scripts.load(_type)
		
		var _script = _scripts.get(_type)
		
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