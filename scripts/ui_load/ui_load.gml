/// @func ui_load(type)
/// @desc Loads a type of UI for use in the current level.
/// @param {UI or string} type The type of UI to load.
function ui_load(_type) {
	if is_string(_type) {
		var _script = global.scripts.fetch(_type)
		
		if _script != undefined and is_instanceof(_script, UIScript) {
			return true
		}
		
		return ui_load(variable_global_get(_type))
	}
	
	if is_instanceof(_type, UI) {
		var _ui = new _type()
		
		_ui.load()
		
		delete _ui
		return true
	}
	
	return false
}