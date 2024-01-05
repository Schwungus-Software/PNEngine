function ui_create(_type, _replace = true) {
	if _replace and global.ui != undefined {
		global.ui.destroy()
	}
	
	var _ui_script = global.scripts.get(_type)
	var _internal_parent = undefined
	
	if is_string(_type) {
		if _ui_script != undefined {
			_internal_parent = _ui_script.internal_parent
		} else {
			_internal_parent = variable_global_get(_type)
			
			if _internal_parent == undefined or not is_instanceof(_internal_parent, UI) {
				show_error($"!!! ui_create: '{_type}' not found", true)
			}
		}
	} else {
		if not is_instanceof(_type, UI) {
			show_error($"!!! ui_create: '{_type}' is not a UI", true)
		}
	}
	
	var _ui = new _internal_parent(_ui_script)
	
	with _ui {
		if create != undefined {
			if is_catspeak(create) {
				create.setSelf(_ui)
			}
			
			create()
		}
		
		if not exists {
			return undefined
		}
	}
	
	if _replace {
		global.ui = _ui
	}
	
	return _ui
}