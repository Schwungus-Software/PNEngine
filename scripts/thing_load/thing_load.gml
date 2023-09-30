/// @func thing_load(index)
/// @desc Loads a type of Thing for use in the current level.
/// @param {Asset.GMObject or string} type The type of Thing to load.
function thing_load(_type, _special = undefined) {
	static _no_special = {}
	
	_special ??= _no_special
	
	if is_string(_type) {
		var _scripts = global.scripts
		
		_scripts.load(_type, _special)
		
		var _script = _scripts.get(_type)
		
		if _script != undefined and is_instanceof(_script, ThingScript) {
			return true
		}
		
		return thing_load(asset_get_index(_type))
	}
	
	if object_exists(_type) {
		with instance_create_depth(0, 0, 0, _type) {
			special = _special
			event_user(ThingEvents.LOAD)
			instance_destroy(id, false)
		}
		
		return true
	}
	
	return false
}