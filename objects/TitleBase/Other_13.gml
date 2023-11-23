/// @description Tick
event_inherited()

if menu != undefined and not locked {
	var _change_option = input_check_opposing_pressed("up", "down", 0, true) + input_check_opposing_repeat("up", "down", 0, true, 3, 12)
	
	if _change_option != 0 and global.title_delete_state <= 1 {
		var _previous = menu.option
		var _new_option
		
		with menu {
			var n = array_length(options)
			
			if n {
				_new_option = _previous
				
				while true {
					option = (option + _change_option) % n
					
					if option < 0 {
						option += n
					}
					
					var _option = options[option]
					
					if _option != undefined and (select_disabled or not _option.disabled) {
						break
					}
				}
				
				_new_option = _new_option != option
			}
		}
		
		if _new_option {
			if is_catspeak(change_option) {
				change_option.setSelf(self)
			}
			
			change_option(_previous)
		}
	}
	
	// Select option
	if input_check_pressed("jump") {
		var _curopt = menu.option
		var _options = menu.options
		var _option = _options[_curopt]
		var _function = _option.func
		
		if is_numeric(_function) {
			var _exit = false
			
			switch _function {
				case TitleOptions.NEW_FILE:
					if global.title_delete_state {
						break
					}
					
					var _netgame = global.netgame
					
					if _netgame != undefined and not _netgame.master {
						break
					}
					
					var i = 1
					
					while file_exists(SAVES_PATH + $"File {i}.sav") {
						++i
					}
					
					global.flags[0].clear()
					
					array_foreach(global.players, function (_element, _index) {
						_element.clear_states()
					})
					
					global.save_name = $"File {i}"
					_exit = true
				break
				
				case TitleOptions.LOAD_FILE:
					if global.title_delete_state >= 1 {
						var _title_delete_state = -~global.title_delete_state
						
						if _title_delete_state == 3 {
							array_delete(_options, _curopt, 1)
							
							var _save = save_data[_curopt]
							
							file_delete(SAVES_PATH + _save.name + ".sav")
							array_delete(save_data, _curopt, 1)
							_title_delete_state = 0
							
							while _options[0] == undefined {
								array_shift(_options)
							}
							
							while _options[menu.option] == undefined {
								if --menu.option < 0 {
									menu.option += array_length(_options)
								}
							}
						}
						
						if is_catspeak(change_delete_state) {
							change_delete_state.setSelf(self)
						}
						
						change_delete_state(_title_delete_state)
						global.title_delete_state = _title_delete_state
						
						break
					}
					
					var _netgame = global.netgame
					
					if _netgame != undefined and not _netgame.master {
						break
					}
					
					var _save = global.saves[| _curopt]
					
					if _save == undefined or _save.code != "" {
						break
					}
					
					with _save {
						global.save_name = name
						
						var _players = global.players
						var i = 0
						
						array_foreach(_players, function (_element, _index) {
							_element.clear_states()
						})
						
						repeat array_length(states) {
							var _player = _players[i]
							var _states = states[i]
							var _names = struct_get_names(_states)
							var j = 0
							
							repeat struct_names_count(_states) {
								var _key = _names[j]
								
								_player.set_state(_key, _states[$ _key]);
								++j
							}
							
							++i
						}
						
						var _global = global.flags[0]
						var _names = struct_get_names(flags)
						
						_global.clear()
						i = 0
						
						repeat struct_names_count(flags) {
							var _key = _names[i]
							
							_global.set(_key, flags[$ _key]);
							++i
						}
						
						var _checkpoint = global.checkpoint
						
						_checkpoint[0] = level
						_checkpoint[1] = area
						_checkpoint[2] = tag
					}
					
					_exit = true
				break
				
				case TitleOptions.DELETE_FILE:
					if is_catspeak(change_delete_state) {
						change_delete_state.setSelf(self)
					}
					
					change_delete_state(1)
					global.title_delete_state = 1
				break
			}
			
			if _exit {
				if is_catspeak(exit_title) {
					exit_title.setSelf(self)
				}
				
				exit_title(_function)
			}
		} else {
			if is_method(_function) {
				if is_catspeak(_function) {
					_function.setSelf(self)
				}
				
				_function()
			}
		}
	}
	
	// Return to previous menu
	if input_check_pressed("pause") {
		if global.title_delete_state {
			if is_catspeak(change_delete_state) {
				change_delete_state.setSelf(self)
			}
			
			change_delete_state(-1)
			global.title_delete_state = -1
		} else {
			set_menu(menu.from, false)
		}
	}
}