function save_game() {
	var _checkpoint = global.checkpoint
	var _cp_level = _checkpoint[0]
	
	if _cp_level == "" {
		print("! save_game: Checkpoint not found")
		
		return false
	}
	
	var _buffer = buffer_create(1, buffer_grow, 1)
	
	// Header
	buffer_write(_buffer, buffer_string, "PNESAVE")
	buffer_write(_buffer, buffer_string, GM_version)
	buffer_write(_buffer, buffer_u32, date_current_datetime())
	
	// Mods
	var _mods = global.mods
	var n = ds_map_size(_mods)
	
	buffer_write(_buffer, buffer_u32, n)
	
	var _key = ds_map_find_first(_mods)
	
	repeat n {
		buffer_write(_buffer, buffer_string, _key)
		buffer_write(_buffer, buffer_string, _mods[? _key].version)
		_key = ds_map_find_next(_mods, _key)
	}
	
	// States
	buffer_write(_buffer, buffer_u8, INPUT_MAX_PLAYERS)
	
	var _players = global.players
	var i = 0
	
	repeat INPUT_MAX_PLAYERS {
		buffer_write(_buffer, buffer_u8, i)
		
		with _players[i] {
			var n = ds_map_size(states)
			
			buffer_write(_buffer, buffer_u32, n)
			
			var _key = ds_map_find_first(states)
			
			repeat n {
				buffer_write(_buffer, buffer_string, _key)
				buffer_write_dynamic(_buffer, states[? _key])
				_key = ds_map_find_next(states, _key)
			}
		}
		
		++i
	}
	
	// Level
	buffer_write(_buffer, buffer_string, _cp_level)
	buffer_write(_buffer, buffer_u32, _checkpoint[1])
	buffer_write(_buffer, buffer_s32, _checkpoint[2])
	
	// Flags
	var _global_flags = global.flags[0].flags
	var n = ds_map_size(_global_flags)
	
	buffer_write(_buffer, buffer_u32, n)
	
	var _key = ds_map_find_first(_global_flags)
	
	repeat n {
		buffer_write(_buffer, buffer_string, _key)
		buffer_write_dynamic(_buffer, _global_flags[? _key])
		_key = ds_map_find_next(_global_flags, _key)
	}
	
	// Output
	var _filename = global.save_name + ".sav"
	
	buffer_save(_buffer, SAVES_PATH + _filename)
	buffer_delete(_buffer)
	print($"save_game: Game saved as '{_filename}'")
	
	return true
}