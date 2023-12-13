function config_load() {
	config_reset()
	
	var _config = global.config
	var _json = json_load(CONFIG_PATH)
	
	if is_struct(_json) {
		var _cvars = variable_struct_get_names(_json)
		var i = 0
		
		repeat array_length(_cvars) {
			var _cvar = _cvars[i]
			
			if variable_struct_exists(_config, _cvar) {
				var _value = _json[$ _cvar]
				
				if _value != undefined {
					_config[$ _cvar] = _value
				}
			}
			
			++i
		}
	}
	
	_json = json_load(CONTROLS_PATH)
	
	if is_struct(_json) {
		input_player_import(_json)
	}
}