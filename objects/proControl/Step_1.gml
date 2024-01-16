if load_state != LoadStates.NONE {
	switch load_state {
		case LoadStates.START:
			load_state = LoadStates.UNLOAD
		break
		
		case LoadStates.UNLOAD:
#region Unload Previous Level
			var _ui = global.ui
			
			if _ui != undefined {
				_ui.destroy()
			}
			
			var _canvases = global.canvases
			var i = 0
			
			repeat array_length(_canvases) {
				_canvases[i++].Flush()
			}
			
			global.ui_sounds.clear()
			
			var _music_instances = global.music_instances
			
			repeat ds_list_size(_music_instances) {
				_music_instances[| 0].destroy()
			}
			
			global.level.destroy()
			
			var _players = global.players
			
			i = 0
			
			repeat INPUT_MAX_PLAYERS {
				with _players[i++] {
					level = undefined
					area = undefined
					thing = noone
					camera = noone
				}
			}
			
			global.images.clear()
			global.materials.clear()
			global.models.clear()
			global.animations.clear()
			//global.fonts.clear()
			global.sounds.clear()
			global.music.clear()
			global.scripts.flush()
			//global.scripts.clear()
			
			var _indices = RNG.indices
			var i = 0
			
			repeat array_length(_indices) {
				_indices[i++] = 0
			}
			
			if load_level == undefined {
				game_end()
				
				exit
			}
			
			flags_force_clear(global.flags[1])
			global.level = new Level()
			gc_collect()
			load_state = LoadStates.LOAD
#endregion
		break
		
		case LoadStates.LOAD:
#region Load New Level
			print($"\n========== {load_level} ({lexicon_text("level." + load_level)}) ==========")
			print($"(Entering area {load_area} from {load_tag})")
			
			var _images = global.images
			
			_images.start_batch()
			
			var _level = global.level
			
			_level.name = load_level
			
			var _json = json_load(mod_find_file("levels/" + load_level + ".json"))
			
			if not is_struct(_json) {
				show_error($"!!! proControl: '{load_level}' not found", true)
			} else {
#region Discord Rich Presence
				_level.rp_name = _json[$ "rp_name"] ?? ""
				_level.rp_icon = _json[$ "rp_icon"] ?? ""
#endregion
				
#region Default Properties
				if _json[$ "checkpoint"] {
					var _checkpoint = global.checkpoint
					
					_checkpoint[0] = load_level
					_checkpoint[1] = load_area
					_checkpoint[2] = load_tag
					save_game()
				}
				
				var _script = _json[$ "script"]
				
				if is_string(_script) {
					with _level {
						level_script = global.scripts.fetch(_script)
						
						if level_script != undefined {
							start = level_script.start
							area_changed = level_script.area_changed
							area_activated = level_script.area_activated
							area_deactivated = level_script.area_deactivated
						}
					}
				}
				
				var _music_tracks = _json[$ "music"]
				
				if _music_tracks != undefined {
					var _music = global.music
					
					if is_string(_music_tracks) {
						_music.load(_music_tracks)
						_level.music = [_music_tracks]
					} else {
						if is_array(_music_tracks) {
							var i = 0
							
							repeat array_length(_music_tracks) {
								var _track = _music_tracks[i]
								var _name
								
								if is_string(_track) {
									_name = _track
								} else {
									if is_struct(_track) {
										_name = _track[$ "name"]
										
										if not is_string(_name) {
											show_error($"!!! proControl: Level has invalid info for music track {i}, struct must have a 'name' member with string", true)
										}
									} else {
										show_error($"!!! proControl: Level has invalid info for music track {i}, expected string or struct", true)
									}
								}
								
								_music.load(_name);
								++i
							}
							
							_level.music = _music_tracks
						} else {
							show_error($"!!! proControl: Level has invalid info for music, expected string or array", true)
						}
					}
				} else {
					_level.music = []
				}
				
				with _level {
					clear_color = color_to_vec5(_json[$ "clear_color"], c_black)
					
					var _fog_distance = _json[$ "fog_distance"]
					
					fog_distance = is_array(_fog_distance) ? [real(_fog_distance[0]), real(_fog_distance[1])] : [0, 65535]
					fog_color = color_to_vec5(_json[$ "fog_color"])
					ambient_color = color_to_vec5(_json[$ "ambient_color"])
					wind_strength = _json[$ "wind_strength"] ?? 1
					
					var _wind_direction = _json[$ "wind_direction"]
					
					wind_direction = is_array(_wind_direction) ? [real(_wind_direction[0]), real(_wind_direction[1]), real(_wind_direction[2])] : [1, 1, 1]
					gravity = _json[$ "gravity"] ?? 0.6
				}
#endregion
				
#region Assets
				var _assets = _json[$ "assets"]
				
				if _assets != undefined {
					// Images
					var __images = _assets[$ "images"]
					
					if __images != undefined {
						repeat array_length(__images) {
							_images.load(array_pop(__images))
						}
					}
					
					// Materials
					var __materials = _assets[$ "materials"]
					
					if __materials != undefined {
						var _materials = global.materials
						
						repeat array_length(__materials) {
							_materials.load(array_pop(__materials))
						}
					}
					
					// Models
					var __models = _assets[$ "models"]
					
					if __models != undefined {
						var _models = global.models
						
						repeat array_length(__models) {
							_models.load(array_pop(__models))
						}
					}
					
					// Fonts
					var __fonts = _assets[$ "fonts"]
					
					if __fonts != undefined {
						var _fonts = global.fonts
						
						repeat array_length(__fonts) {
							_fonts.load(array_pop(__fonts))
						}
					}
					
					// Sounds
					var __sounds = _assets[$ "sounds"]
					
					if __sounds != undefined {
						var _sounds = global.sounds
						
						repeat array_length(__sounds) {
							_sounds.load(array_pop(__sounds))
						}
					}
					
					// Music
					var __music = _assets[$ "music"]
					
					if __music != undefined {
						var _music = global.music
						
						repeat array_length(__music) {
							_music.load(array_pop(__music))
						}
					}
					
					// Things
					var _things = _assets[$ "things"]
					
					if _things != undefined {
						repeat array_length(_things) {
							var _thing = array_pop(_things)
							var _thing_index = asset_get_index(_thing)
							
							if _thing_index != -1 {
								if string_starts_with(_thing, "pro") {
									print($"! proControl: Can't load protected Thing '{_thing}'!")
									
									continue
								}
								
								thing_load(_thing_index)
							} else {
								thing_load(_thing)
							}
						}
					}
				}
#endregion
				
#region Areas
				var _add_areas = _json[$ "areas"]
				
				if not is_array(_add_areas) {
					show_error($"!!! proControl: Level '{load_level}' has no areas", true)
				} else {
					var _thing_slot = 0
					
					var _areas = _level.areas
					var _images = global.images
					var _models = global.models
					var _scripts = global.scripts
					
					var _current_area_pos = 0
					
					repeat array_length(_add_areas) {
						var _area = new Area()
						var _area_info = _add_areas[_current_area_pos++]
						
						// Check for valid ID
						var _id = _area_info[$ "id"] ?? undefined
						
						if is_real(_id) {
							with _area {
								level = _level
								slot = _id
								ds_map_add(_areas, _id, _area)
								
								var _clear_color = _area_info[$ "clear_color"]
								var _ambient_color = _area_info[$ "ambient_color"]
								var _fog_distance = _area_info[$ "fog_distance"]
								var _fog_color = _area_info[$ "fog_color"]
								var _wind_direction = _area_info[$ "wind_direction"]
								
								clear_color = _clear_color == undefined ? _level.clear_color : color_to_vec5(_clear_color)
								ambient_color = _ambient_color == undefined ? _level.ambient_color : color_to_vec5(_ambient_color)
								fog_distance = is_array(_fog_distance) ? [real(_fog_distance[0]), real(_fog_distance[1])] : _level.fog_distance
								fog_color = _fog_color == undefined ? _level.fog_color : color_to_vec5(_fog_color)
								wind_strength = _area_info[$ "wind_strength"] ?? _level.wind_strength
								wind_direction = _wind_direction == undefined ? _level.wind_direction : [real(_wind_direction[0]), real(_wind_direction[1]), real(_wind_direction[2])]
								gravity = _area_info[$ "gravity"] ?? _level.gravity
							}
							
							// Check for model
							var _model_name = _area_info[$ "model"]
							
							if is_string(_model_name) {
								var _model = _models.fetch(_model_name)
								
								if _model != undefined {
									with _area {
										model = new ModelInstance(_model)
										
										var _collider = _model.collider
										
										if _collider != undefined {
											collider = new ColliderInstance(_collider)
										}
									}
								}
							}
							
							// Check for things
							var _things = _area.things
							var _add_things = _area_info[$ "things"]
							var _bump_x1 = infinity
							var _bump_y1 = infinity
							var _bump_x2 = -infinity
							var _bump_y2 = -infinity
							
							if is_array(_add_things) {
								_images.load("imgShadow")
								
								var _area_things = _level.area_things
								var i = 0
								
								repeat array_length(_add_things) {
									var _area_thing = new AreaThing()
									var _thing_info = _add_things[i]
									
									with _area_thing {
										level = _level
										area = _area
										slot = _thing_slot
										
										var _type_name = _thing_info[$ "type"]
										
										type = asset_get_index(_type_name)
										
										if type == -1 {
											type = _type_name
										}
										
										if string_starts_with(_type_name, "pro") {
											print($"! proControl: Can't load protected Thing '{_type_name}' in area {_id}!")
											
											delete _area_thing
										} else {
											var _special = _thing_info[$ "special"]
											
											if thing_load(type, _special) {
												x = _thing_info[$ "x"] ?? 0
												y = _thing_info[$ "y"] ?? 0
												z = _thing_info[$ "z"] ?? 0
												
												_bump_x1 = min(_bump_x1, x - COLLIDER_REGION_RADIUS)
												_bump_y1 = min(_bump_y1, y - COLLIDER_REGION_RADIUS)
												_bump_x2 = max(_bump_x2, x + COLLIDER_REGION_RADIUS)
												_bump_y2 = max(_bump_y2, y + COLLIDER_REGION_RADIUS)
												
												angle = _thing_info[$ "angle"] ?? 0
												tag = _thing_info[$ "tag"] ?? 0
												special = _special
												persistent = _thing_info[$ "persistent"] ?? false
												disposable = _thing_info[$ "disposable"] ?? false
												array_push(_things, _area_thing)
											} else {
												print($"! proControl: Unknown Thing '{_type_name}' in area {_id}")
												
												delete _area_thing
											}
										}
										
										++_thing_slot
										ds_list_add(_area_things, _area_thing)
									}
									
									++i
								}
							}
							
							with _area {
								var n = array_length(_things)
							
								if n {
									/* The size of the bump grid is based on the leftmost and rightmost
									   area thing positions. Any Things outside of this grid will have
									   their region clamped accordingly. */
									var _width = ceil(abs(_bump_x2 - _bump_x1) * COLLIDER_REGION_SIZE_INVERSE)
									var _height = ceil(abs(_bump_y2 - _bump_y1) * COLLIDER_REGION_SIZE_INVERSE)
								
									ds_grid_resize(bump_grid, _width, _height)
									ds_grid_resize(bump_lists, _width, _height)
								
									var i = 0
								
									repeat ds_grid_width(bump_lists) {
										var j = 0
									
										repeat ds_grid_height(bump_lists) {
											bump_lists[# i, j++] = ds_list_create()
										}
									
										++i
									}
								
									bump_x = _bump_x1
									bump_y = _bump_y1
								} else {
									// This level has no area actors, set defaults
									bump_lists[# 0, 0] = ds_list_create()
								}
							}
						} else {
							print($"! proControl: Invalid area ID '{_id}', expected real")
							
							delete _area
						}
						
						delete _area_info
					}
				}
#endregion
				
				var _copy_flags = _json[$ "flags"]
				
				if is_struct(_copy_flags) {
					var _flags = global.flags
					var _copy_global = _copy_flags[$ "global"]
					
					if is_struct(_copy_global) {
						flags_force_copy(_flags[0], _copy_global)
					}
					
					var _copy_local = _copy_flags[$ "local"]
					
					if is_struct(_copy_local) {
						flags_force_copy(_flags[1], _copy_local)
					}
				}
				
				delete _json
			}
			
			ui_load("Pause")
			
			_images.end_batch()
			
			var _materials_map = global.materials.assets
			var _key = ds_map_find_first(_materials_map)
			
			repeat ds_map_size(_materials_map) {
				with _materials_map[? _key] {
					if image != -1 {
						image = CollageImageGetInfo(image)
					}
					
					if image2 != undefined and image2 != -1 {
						image2 = CollageImageGetInfo(image2)
					}
				}
				
				_key = ds_map_find_next(_materials_map, _key)
			}
			
			load_state = LoadStates.FINISH
#endregion
		break
		
		case LoadStates.FINISH:
#region Finish Loading
			game_update_status()
			
			var _level = global.level
			var _players = global.players
			var i = 0
			var _load_area = load_area
			
			with _level {
				repeat array_length(music) {
					var _track = music[i]
					var _asset
					
					if is_string(_track) {
						_asset = global.music.get(_track)
						
						var _inst = new MusicInstance(_asset, i)
					} else {
						if is_struct(_track) {
							_asset = global.music.get(_track[$ "name"])
							
							var _inst = new MusicInstance(_asset, _track[$ "priority"] ?? i, _track[$ "loop"] ?? true, 1, 0, _track[$ "active"] ?? true)
						}
					}
					
					music[i] = _asset;
					++i
				}
			}
			
			i = 0
			
			repeat INPUT_MAX_PLAYERS {
				var _player = _players[i++]
				
				with _player {
					level = _level
					
					// Bring new players in-game
					if status == PlayerStatus.PENDING {
						status = PlayerStatus.ACTIVE;
						++global.players_active;
						--global.players_ready
					}
					
					if status == PlayerStatus.ACTIVE {
						player_force_area(_player, _load_area)
					}
				}
			}
			
			with proTransition {
				if state == 2 {
					state = 3
				}
			}
			
			load_state = LoadStates.NONE
			
			with _level {
				if start != undefined {
					start(_level)
				}
			}
#endregion
		break
		
		case LoadStates.NETGAME_START: break
		
		case LoadStates.NETGAME_FINISH:
			load_state = LoadStates.NONE
		break
		
		case LoadStates.NETGAME_LEVEL:
#region Wait For Players
			// During this state, the host will wait until every player has
			// received a level change packet then change the level.
			var _netgame = global.netgame
			
			if _netgame == undefined {
				load_state = LoadStates.START
				
				break
			}
			
			var _ready = true
			
			with _netgame {
				var i = 0
				
				repeat ds_list_size(players) {
					var _player = players[| i++]
					
					if _player == undefined {
						continue
					}
					
					if not _player.ready {
						_ready = false
						
						break
					}
				}
			}
			
			if _ready {
				load_state = LoadStates.START
			}
#endregion
		break
	}
	
	// Don't tick while loading
	exit
}

if global.freeze_step {
	// Don't tick for this frame
	global.freeze_step = false
	
	exit
}

var _ui = global.ui
var _mouse_focused = global.mouse_focused
var _mouse_dx, _mouse_dy

if _mouse_focused {
	if window_has_focus() and _ui == undefined {
		_mouse_dx = window_mouse_get_delta_x()
		_mouse_dy = window_mouse_get_delta_y()
	} else {
		window_mouse_set_locked(false)
		global.mouse_focused = false
		_mouse_focused = false
		_mouse_dx = 0
		_mouse_dy = 0
	}
} else {
	if window_has_focus() and _ui == undefined {
		window_mouse_set_locked(true)
		global.mouse_focused = true
		_mouse_focused = true
	}
	
	_mouse_dx = 0
	_mouse_dy = 0
}

var _tick = global.tick
var _tick_inc = (delta_time * TICKRATE_DELTA) * global.tick_scale

global.delta = _tick_inc
_tick += _tick_inc

// Cache a lot of things into local variables
var _console = global.console
var _chat_typing = global.chat_typing
var _interps = global.interps
var _players = global.players
var _config = global.config
var _game_status = global.game_status
var _netgame = global.netgame
var _syncables = global.level.syncables

if _tick >= 1 {
	__input_system_tick()
	
#region New Players
	with input_players_get_status() {
		if any_changed {
			print($"proControl: Player input status updated ({new_connections}, {new_disconnections})")
			var i = 0
		
			repeat array_length(new_connections) {
				with _players[new_connections[i++]] {
					if not activate() {
						if __show_reconnect_caption {
							var _device = input_player_get_gamepad_type(slot)
						
							if _device == "unknown" {
								_device = "no controller"
							}
						
							show_caption($"[c_lime]Player {-~slot} reconnected! ({_device})")
						} else {
							__show_reconnect_caption = true
						}
					}
				}
			}
			
			i = 0
			
			repeat array_length(new_disconnections) {
				with _players[new_disconnections[i++]] {
					if not deactivate() {
						show_caption($"[c_red]Player {-~slot} disconnected. Press any key to reconnect.")
					}
				}
			}
		}
	}
#endregion
		
#region Debug
	if input_check_pressed("debug_overlay") {
		global.debug_overlay = not global.debug_overlay
		show_debug_overlay(global.debug_overlay)
	}
	
	if _chat_typing {
		// Boring list of inputs we have to block while typing...
		input_verb_consume("up")
		input_verb_consume("left")
		input_verb_consume("down")
		input_verb_consume("right")
		input_verb_consume("jump")
		input_verb_consume("interact")
		input_verb_consume("attack")
		input_verb_consume("inventory_up")
		input_verb_consume("inventory_left")
		input_verb_consume("inventory_down")
		input_verb_consume("inventory_right")
		input_verb_consume("aim")
		input_verb_consume("aim_up")
		input_verb_consume("aim_left")
		input_verb_consume("aim_down")
		input_verb_consume("aim_right")
		input_verb_consume("leave")
		input_verb_consume("chat")
		input_verb_consume("voice")
		input_verb_consume("debug_console")
		_mouse_dx = 0
		_mouse_dy = 0
		
		if input_check_pressed("chat_previous") {
			keyboard_string = global.chat_input_previous
		}
		
		if input_check_pressed("chat_submit") {
			global.chat_typing = false
			
			var _input = string_trim(keyboard_string)
			
			if _input != "" {
				cmd_say(_input)
				global.chat_input_previous = _input
			}
			
			keyboard_string = ""
		}
		
		if input_check_pressed("pause") {
			input_verb_consume("pause")
			global.chat_typing = false
		}
	} else {
		if input_check_pressed("chat") and _netgame != undefined and _netgame.active {
			global.chat_typing = true
			keyboard_string = ""
		}
	}
	
	if _console {
		input_verb_consume("leave")
		
		if input_check_pressed("debug_console_previous") {
			keyboard_string = global.console_input_previous
		}
		
		if input_check_pressed("debug_console_submit") {
			var _input = string_trim(keyboard_string)
			
			if _input != "" {
				global.console_input_previous = _input
				print($"> {_input}")
				
				array_foreach(string_split(_input, ";", true), function (_element, _index) {
					var _input = string_trim(_element)
				
					if _input != "" {
						var _cmd = _input
						var _args = ""
						var _args_pos = string_pos(" ", _cmd)
					
						if _args_pos > 0 {
							_cmd = string_copy(_cmd, 1, _args_pos - 1)
							_args = string_delete(_input, 1, _args_pos)
						}
					
						var _cmd_function = variable_global_get($"cmd_{_cmd}")
					
						if is_method(_cmd_function) {
							_cmd_function(_args)
						} else {
							print($"Unknown command '{_cmd}'")
						}
					}
				})
			}
			
			keyboard_string = ""
		}
		
		if input_check_pressed("pause") {
			if _netgame == undefined {
				input_source_mode_set(INPUT_SOURCE_MODE.JOIN)
			}
			
			input_verb_consume("pause")
			global.console = false
			global.console_input = keyboard_string
		}
		
		if _game_status & GameStatus.NETGAME {
			// Gross hack, will clean up later
			input_verb_consume("up")
			input_verb_consume("left")
			input_verb_consume("down")
			input_verb_consume("right")
			input_verb_consume("jump")
			input_verb_consume("interact")
			input_verb_consume("attack")
			input_verb_consume("inventory_up")
			input_verb_consume("inventory_left")
			input_verb_consume("inventory_down")
			input_verb_consume("inventory_right")
			input_verb_consume("aim")
			input_verb_consume("aim_up")
			input_verb_consume("aim_left")
			input_verb_consume("aim_down")
			input_verb_consume("aim_right")
			input_verb_consume("leave")
			input_verb_consume("chat")
			input_verb_consume("chat_submit")
			input_verb_consume("voice")
			_mouse_dx = 0
			_mouse_dy = 0
		} else {
			_tick = 0
		}
	} else {
		if input_check_pressed("debug_console") {
			input_source_mode_set(INPUT_SOURCE_MODE.FIXED)
			global.console = true
			keyboard_string = global.console_input
		}
	}
#endregion
	
#region Start Interpolation
	var i = ds_list_size(_interps)
	var _gc = false
	
	repeat i {
		var _scope = _interps[| --i]
		
		if _scope == undefined {
			continue
		}
		
		var _ref
		
		if is_numeric(_scope) {
			if instance_exists(_scope) {
				_ref = _scope
			} else {
				_gc = true
				_interps[| i] = undefined
				
				continue
			}
		} else {
			if weak_ref_alive(_scope) {
				_ref = _scope.ref
			} else {
				_gc = true
				_interps[| i] = undefined
				
				continue
			}
		}
		
		with _ref {
			var j = 0
			
			repeat array_length(__interp) {
				var _element = __interp[j++]
				
				_element[InterpData.PREVIOUS_VALUE] = struct_get_from_hash(self, _element[InterpData.IN_HASH])
			}
		}
	}
	
	/* GROSS HACKS: There are memory leaks because structs are never being
					dereferenced for some reason. Not sure if this is
					related to Catspeak or the interpolator in general.
					Whenever a dead instance or struct is removed from the
					interpolator, call the GC just in case. */
	if _gc {
		gc_collect()
	}
#endregion
	
#region Game Loop
	while _tick >= 1 {
#region Transition
		var _skip_tick = false
		
		with proTransition {
			event_user(ThingEvents.TICK)
			
			// Freeze the world while the screen is fading in
			switch state {
				case 1:
					with proControl {
						load_level = other.to_level
						load_area = other.to_area
						load_tag = other.to_tag
						load_state = LoadStates.START
					}
					
					state = 2
					
				case 0:
				case 2:
					_skip_tick = true
				break
			}
		}
		
		_ui = global.ui
		
		if _ui != undefined {
			var _ui_input = global.ui_input
			
			_ui_input[UIInputs.UP_DOWN] = input_check_opposing_pressed("up", "down", 0, true) + input_check_opposing_repeat("up", "down", 0, true, 1, 12)
			_ui_input[UIInputs.LEFT_RIGHT] = input_check_opposing_pressed("left", "right", 0, true) + input_check_opposing_repeat("left", "right", 0, true, 1, 12)
			_ui_input[UIInputs.CONFIRM] = input_check_pressed("jump")
			_ui_input[UIInputs.BACK] = input_check_pressed("pause")
			
			var _tick_target = _ui
			
			while true {
				var _child = _tick_target.child
				
				if _child == undefined {
					break
				}
				
				_tick_target = _child
			}
			
			with _tick_target {
				if tick != undefined {
					tick(_tick_target)
				}
				
				if exists and f_blocking {
					if _game_status & GameStatus.NETGAME {
						// Gross hack, will clean up later
						input_verb_consume("up")
						input_verb_consume("left")
						input_verb_consume("down")
						input_verb_consume("right")
						input_verb_consume("jump")
						input_verb_consume("interact")
						input_verb_consume("attack")
						input_verb_consume("inventory_up")
						input_verb_consume("inventory_left")
						input_verb_consume("inventory_down")
						input_verb_consume("inventory_right")
						input_verb_consume("aim")
						input_verb_consume("aim_up")
						input_verb_consume("aim_left")
						input_verb_consume("aim_down")
						input_verb_consume("aim_right")
						//input_verb_consume("leave")
						input_verb_consume("chat")
						input_verb_consume("chat_submit")
						input_verb_consume("voice")
					} else {
						_skip_tick = true
					}
				}
			}
		} else {
			var _paused = false
			
			if input_check_pressed("pause") {
				_paused = true
				
				if not (_game_status & GameStatus.NETGAME) {
					var i = INPUT_MAX_PLAYERS
					
					repeat i {
						with _players[--i] {
							if status != PlayerStatus.ACTIVE {
								break
							}
						
							if not instance_exists(thing) or get_state("frozen") {
								_paused = false
								
								break
							}
						}
						
						if not _paused {
							break
						}
					}
				}
			}
			
			if _paused {
				ui_create("Pause")
				_skip_tick = true
			}
		}
		
		if _skip_tick {
			_mouse_dx = 0
			_mouse_dy = 0
			input_clear_momentary(true);
			--_tick
			
			continue
		}
#endregion
		
#region Players
		var i = 0
		
		repeat INPUT_MAX_PLAYERS {
			with _players[i] {
				if status != PlayerStatus.ACTIVE {
					break
				}
#region Input
				array_copy(input_previous, 0, input, 0, PlayerInputs.__SIZE)
				
				var _get_input = false
				var _index = i
				var _mouse = false
				
				if _game_status & GameStatus.NETGAME {
					if _netgame.local_slot == i {
						_get_input = true
						_index = 0
						_mouse = _mouse_focused
					}
				} else {
					_get_input = true
					_mouse = _index == 0 and _mouse_focused
				}
				
				if _get_input {
					// Main
					var _move_range = input_check("walk", _index) ? 64 : 127
					var _input_up_down = floor(input_check_opposing("up", "down", _index, true) * _move_range)
					var _input_left_right = floor(input_check_opposing("left", "right", _index, true) * _move_range)
					var _input_jump = input_check("jump", _index)
					var _input_interact = input_check("interact", _index)
					var _input_attack = input_check("attack", _index)
					
					// Inventory
					var _input_inventory_up = input_check("inventory_up", _index)
					var _input_inventory_left = input_check("inventory_left", _index)
					var _input_inventory_down = input_check("inventory_down", _index)
					var _input_inventory_right = input_check("inventory_right", _index)
					
					// Camera
					var _input_aim = input_check("aim", _index)
					
					// Write to input array
					input[PlayerInputs.UP_DOWN] = _input_up_down
					input[PlayerInputs.LEFT_RIGHT] = _input_left_right
					input[PlayerInputs.JUMP] = _input_jump
					input[PlayerInputs.INTERACT] = _input_interact
					input[PlayerInputs.ATTACK] = _input_attack
					input[PlayerInputs.INVENTORY_UP] = _input_inventory_up
					input[PlayerInputs.INVENTORY_LEFT] = _input_inventory_left
					input[PlayerInputs.INVENTORY_DOWN] = _input_inventory_down
					input[PlayerInputs.INVENTORY_RIGHT] = _input_inventory_right
					input[PlayerInputs.AIM] = _input_aim
					
					// This one kinda sucks...
					var _dx_factor = input_check_opposing("aim_left", "aim_right", _index, true)
					var _dy_factor = input_check_opposing("aim_up", "aim_down", _index, true)
					var _dx_angle, _dy_angle
					
					with _config {
						_dx_angle = in_pan_x * (in_invert_x ? -1 : 1)
						_dy_angle = in_pan_y * (in_invert_y ? -1 : 1)
						
						if _mouse {
							_dx_factor += _mouse_dx * in_mouse_x
							_dy_factor += _mouse_dy * in_mouse_y
						}
					}
					
					var _input_force_left_right = input[PlayerInputs.FORCE_LEFT_RIGHT]
					
					if is_nan(_input_force_left_right) {
						var _dx = round(((_dx_factor * _dx_angle) * 0.0027777777777778) * 32768)
						
						input[PlayerInputs.AIM_LEFT_RIGHT] = (input[PlayerInputs.AIM_LEFT_RIGHT] - _dx) % 32768
					} else {
						input[PlayerInputs.AIM_LEFT_RIGHT] = round(_input_force_left_right * PLAYER_AIM_DIRECT) % 32768
						input[PlayerInputs.FORCE_LEFT_RIGHT] = NaN
					}
					
					var _input_force_up_down = input[PlayerInputs.FORCE_UP_DOWN]
					
					if is_nan(_input_force_up_down) {
						var _dy = round(((_dy_factor * _dy_angle) * 0.0027777777777778) * 32768)
						
						input[PlayerInputs.AIM_UP_DOWN] = (input[PlayerInputs.AIM_UP_DOWN] - _dy) % 32768
					} else {
						input[PlayerInputs.AIM_UP_DOWN] = round(_input_force_up_down * PLAYER_AIM_DIRECT) % 32768
						input[PlayerInputs.FORCE_UP_DOWN] = NaN
					}
					
					if _game_status & GameStatus.NETGAME and not array_equals(input, input_previous) {
						// Send input data to the server
						var b = net_buffer_create(false, NetHeaders.INPUT)
						
						buffer_write(b, buffer_s8, _input_up_down)
						buffer_write(b, buffer_s8, _input_left_right)
						buffer_write(b, buffer_bool, _input_jump)
						buffer_write(b, buffer_bool, _input_interact)
						buffer_write(b, buffer_bool, _input_attack)
						buffer_write(b, buffer_bool, _input_inventory_up)
						buffer_write(b, buffer_bool, _input_inventory_left)
						buffer_write(b, buffer_bool, _input_inventory_down)
						buffer_write(b, buffer_bool, _input_inventory_right)
						buffer_write(b, buffer_bool, _input_aim)
						buffer_write(b, buffer_s16, input[PlayerInputs.AIM_UP_DOWN])
						buffer_write(b, buffer_s16, input[PlayerInputs.AIM_LEFT_RIGHT])
						_netgame.send(SEND_OTHERS, b)
					}
				} else {
					if _game_status & GameStatus.NETGAME {
						while ds_queue_size(input_queue) {
							input[PlayerInputs.UP_DOWN] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.LEFT_RIGHT] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.JUMP] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.INTERACT] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.ATTACK] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.INVENTORY_UP] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.INVENTORY_LEFT] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.INVENTORY_DOWN] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.INVENTORY_RIGHT] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.AIM] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.AIM_UP_DOWN] = ds_queue_dequeue(input_queue)
							input[PlayerInputs.AIM_LEFT_RIGHT] = ds_queue_dequeue(input_queue)
						}
					}
				}
#endregion
				
#region Area
				if area != undefined {
					with area {
						if master != other {
							break
						}
						
						var _players_in_area = players
						var _nthings = ds_list_size(active_things)
						
						// Add actors to actor collision grid
						var _bump_grid = bump_grid
						var _bump_lists = bump_lists
						var _bump_x = bump_x
						var _bump_y = bump_y
						var _bump_width = ds_grid_width(_bump_grid)
						var _bump_height = ds_grid_height(_bump_grid)
						var _bump_max_x = _bump_width - 1
						var _bump_max_y = _bump_height - 1
						
						ds_grid_clear(_bump_grid, false)
						
						var j = 0
						
						repeat _nthings {
							with active_things[| j++] {
								if m_bump == MBump.NONE or f_culled or f_frozen {
									continue
								}
								
								var _gx = (x - _bump_x) * COLLIDER_REGION_SIZE_INVERSE
								var _gy = (y - _bump_y) * COLLIDER_REGION_SIZE_INVERSE
								var _gr = bump_radius * COLLIDER_REGION_SIZE_INVERSE
								
								var _gx1 = clamp(floor(_gx - _gr), 0, _bump_max_x)
								var _gy1 = clamp(floor(_gy - _gr), 0, _bump_max_y)
								var _gx2 = clamp(ceil(_gx + _gr), 1, _bump_width)
								var _gy2 = clamp(ceil(_gy + _gr), 1, _bump_height)
								
								var _gi = _gx1
								
								repeat _gx2 - _gx1 {
									var _gj = _gy1
									
									repeat _gy2 - _gy1 {
										var _list = _bump_lists[# _gi, _gj]
										
										if not _bump_grid[# _gi, _gj] {
											_bump_grid[# _gi, _gj] = true
											ds_list_clear(_list)
										}
										
										ds_list_add(_list, id);
										++_gj
									}
									
									++_gi
								}
							}
						}
						
						j = _nthings
						
						repeat j {
							with active_things[| --j] {
								var _can_tick = true
								
								if cull_tick != infinity {
									_can_tick = false
									
									var _ox = x
									var _oy = y
									var _od = cull_tick
									var k = ds_list_size(_players_in_area)
									
									repeat k {
										with _players_in_area[| --k] {
											if instance_exists(thing) {
												with thing {
													if point_distance(x, y, _ox, _oy) < _od {
														_can_tick = true
													}
												}
											}
											
											if _can_tick {
												break
											}
										}
										
										if _can_tick {
											break
										}
									}
								}
								
								if _can_tick {
									f_culled = false
									
									if not f_frozen {
										event_user(ThingEvents.TICK)
									}
								} else {
									f_culled = true
									
									if f_cull_destroy {
										destroy(false)
										
										break
									}
								}
#region Thing Syncing
								if not (_game_status & GameStatus.NETGAME) or not f_sync or not _netgame.master {
									break
								}
								
								++_syncables[# sync_id, 1]
								
								if _syncables[# sync_id, 1] >= SYNC_INTERVAL {
									var b = net_buffer_create(false, NetHeaders.HOST_THING)
									
									buffer_write(b, buffer_u16, sync_id)
									buffer_write(b, buffer_u32, area.slot)
									buffer_write(b, buffer_string, thing_script != undefined ? thing_script.name : object_get_name(object_index))
									
									var _n_pos = buffer_tell(b)
									
									buffer_write(b, buffer_u8, 0)
									
									var n = ds_list_size(net_variables)
									
									if n {
										var k = 0
										var l = 0
										
										repeat n {
											var _netvar = net_variables[| k]
											
											with _netvar {
												if not (flags & NetVarFlags.TICK) {
													break
												}
												
												var _value
												
												if write != undefined {
													_value = write(scope)
												} else {
													_value = struct_get_from_hash(scope, hash)
												}
												
												value = _value
												buffer_write(b, buffer_u8, k)
												buffer_write_dynamic(b, _value);
												++l
											}
											
											++k
										}
										
										buffer_poke(b, _n_pos, buffer_u8, l)
									}
									
									_netgame.send(SEND_OTHERS, b)
								}
#endregion
							}
						}
					}
				}
			}
			
			++i
		}
#endregion
		
		_mouse_dx = 0
		_mouse_dy = 0
		input_clear_momentary(true);
		--_tick
	}
#endregion
#endregion
}

global.tick = _tick

#region End Interpolation
var _gc = false
var i = ds_list_size(_interps)

if _tick_inc >= 1 {
#region Interpolation OFF (FPS <= TICKRATE)
	repeat i {
		var _scope = _interps[| --i]
		
		if _scope == undefined {
			continue
		}
		
		var _ref
		
		if is_numeric(_scope) {
			if instance_exists(_scope) {
				_ref = _scope
			} else {
				_gc = true
				_interps[| i] = undefined
				
				continue
			}
		} else {
			if weak_ref_alive(_scope) {
				_ref = _scope.ref
			} else {
				_gc = true
				_interps[| i] = undefined
				
				continue
			}
		}
		
		with _ref {
			var j = 0
			
			repeat array_length(__interp) {
				var _element = __interp[j++]
				
				struct_set_from_hash(self, _element[InterpData.OUT_HASH], struct_get_from_hash(self, _element[InterpData.IN_HASH]))
			}
		}
	}
#endregion
} else {
#region Interpolation ON (FPS > TICKRATE)
	repeat i {
		var _scope = _interps[| --i]
		
		if _scope == undefined {
			continue
		}
		
		var _ref
		
		if is_numeric(_scope) {
			if instance_exists(_scope) {
				_ref = _scope
			} else {
				_gc = true
				_interps[| i] = undefined
				
				continue
			}
		} else {
			if weak_ref_alive(_scope) {
				_ref = _scope.ref
			} else {
				_gc = true
				_interps[| i] = undefined
				
				continue
			}
		}
		
		with _ref {
			var j = 0
			
			repeat array_length(__interp) {
				var _child = __interp[j++]
				
				struct_set_from_hash(_ref, _child[InterpData.OUT_HASH], (_child[InterpData.ANGLE] ? lerp_angle : lerp)(_child[InterpData.PREVIOUS_VALUE], struct_get_from_hash(_ref, _child[InterpData.IN_HASH]), _tick)) // This line is already long enough, but why not make it even longer with this useless comment?
			}
		}
	}
#endregion
}

/* GROSS HACKS: There are memory leaks because structs are never being
				dereferenced for some reason. Not sure if this is
				related to Catspeak or the interpolator in general.
				Whenever a dead instance or struct is removed from the
				interpolator, call the GC just in case. */
if _gc {
	gc_collect()
}
#endregion