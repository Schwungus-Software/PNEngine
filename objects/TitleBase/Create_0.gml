enum TitleOptions {
	NEW_FILE,
	LOAD_FILE,
	DELETE_FILE,
	OPTIONS,
}

event_inherited()

f_unique = true
f_sync = false

title_start = global.title_start
menu = undefined
locked = false
save_data = []

#region Constructors
function TitleMenu(_name, _options, _select_disabled) constructor {
	name = _name
	options = _options
	option = 0
	from = undefined
	select_disabled = _select_disabled
}

function TitleOption(_name, _function, _disabled) constructor {
	name = _name
	func = _function
	disabled = _disabled
}

function TitleSave(_save) constructor {
	name = _save.name
	code = _save.code
	date = _save.date
	states = variable_clone(_save.states)
	flags = variable_clone(_save.flags)
	level = _save.level
}
#endregion

#region Functions
add_menu = function (_name, _options = [], _select_disabled = false) {
	return new TitleMenu(_name, _options, _select_disabled)
}

add_option = function (_name, _function = undefined, _disabled = false) {
	if _function == TitleOptions.DELETE_FILE {
		_disabled = not array_length(save_data)
	}
	
	return new TitleOption(_name, _function, _disabled)
}

set_menu = function (_menu, _allow_return = true) {
	if _menu != undefined and not global.title_delete_state {
		with _menu {
			from = _allow_return ? other.menu : undefined
			
			var n = array_length(options)
			
			if n {
				var _option = options[option]
				
				while _option == undefined or (not select_disabled and _option.disabled) {
					option = -~option % n
					_option = options[option]
				}
			}
		}
		
		var _previous = menu
		
		menu = _menu
		
		if is_catspeak(change_menu) {
			change_menu.setSelf(self)
		}
		
		change_menu(_previous)
		
		return true
	}
	
	return false
}

/*request_result = function (_interaction, _option = 0) {
	switch _interaction {
		case TitleInteractions.DELETE_FILE:
			var _saves = global.saves
			var _save = _saves[| _option]
			
			if _save == undefined {
				return false
			}*/
			
			/* This won't actually delete the save, but move it to
			   saves/deleted. This is so that any maliciously deleted save can
			   be recovered as long as it isn't overwritten. */
			/*var _filename = _save.filename
			var _path = "saves/" + _filename
			
			if not file_exists(_path) {
				return false
			}
			
			file_copy(_path, "saves/deleted/" + _filename)
			file_delete(_path)
			ds_list_delete(_saves, _option)
			array_delete(save_data, _option, 1)
			
			return true
			
		case TitleInteractions.OPTIONS:
			return true
	}
	
	return false
}*/
#endregion

#region Virtual Functions
change_menu = function (_previous) {}

change_option = function (_previous) {}

change_delete_state = function (_state) {}

exit_title = function (_option) {}
#endregion