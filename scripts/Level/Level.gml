function Level() constructor {
	name = ""
	areas = ds_map_create()
	
	rp_name = ""
	rp_icon = ""
	rp_time = false
	
	music = undefined
	clear_color = undefined
	ambient_color = undefined
	wind_strength = 1
	wind_direction = undefined
	gravity = 0.6
	
	time = 0
	
	level_script = undefined
	
	start = undefined
	area_changed = undefined
	area_activated = undefined
	area_deactivated = undefined
	
	/// @desc Destroys the contents of the level, allowing it to be removed.
	static destroy = function () {
		repeat ds_map_size(areas) {
			var _key = ds_map_find_first(areas)
			
			areas[? _key].destroy()
			ds_map_delete(areas, _key)
		}
		
		ds_map_destroy(areas)
	}
	
	static goto = function (_level, _area = 0, _tag = ThingTags.NONE, _transition = noone) {
		set_tick_scale(1)
		
		if net_active() {
			instance_destroy(proTransition)
			
			with global.netgame {
				if _level == undefined {
					exit
				}
				
				if not master {
					proControl.load_state = LoadStates.CLIENT_WAIT
					
					exit
				}
				
				var i = 0
				
				repeat ds_list_size(players) {
					var _player = players[| i++]
					
					if _player != undefined and not _player.local {
						_player.ready = false
					}
				}
				
				if global.level.name == "lvlTitle" {
					var b = net_buffer_create(true, NetHeaders.HOST_STATES_FLAGS, buffer_u8, INPUT_MAX_PLAYERS)
					
					// States
					var _players = global.players
					var i = 0
					
					repeat INPUT_MAX_PLAYERS {
						buffer_write(b, buffer_u8, i)
						_players[i++].write_states(b)
					}
					
					// Flags
					global.flags[FlagGroups.GLOBAL].write(b)
					
					send(SEND_OTHERS, b)
				}
				
				send(SEND_OTHERS, net_buffer_create(true, NetHeaders.HOST_LEVEL, buffer_string, _level, buffer_u32, _area, buffer_s32, _tag))
			}
		} else {
			with proTransition {
				if state < 3 {
					exit
				}
			}
			
			var _script = undefined
			
			if is_string(_transition) {
				if string_starts_with(_transition, "pro") {
					show_error($"!!! Level.goto: Tried to transition to level using protected Transition '{_transition}'", true)
				}
				
				var _index = asset_get_index(_transition)
				
				if not object_exists(_index) or not object_is_ancestor(_index, proTransition) {
					_script = global.scripts.get(_transition)
					
					if _script != undefined and is_instanceof(_script, TransitionScript) {
						_index = _script.internal_parent
					} else {
						_index = noone
						print($"! Level.goto: Transition '{_transition}' not found")
					}
				}
				
				_transition = _index
			}
			
			if object_exists(_transition) and (_transition == proTransition or object_is_ancestor(_transition, proTransition)) {
				with instance_create_depth(0, 0, 0, _transition) {
					if _script != undefined {
						transition_script = _script
						reload = _script.reload
						create = _script.create
						clean_up = _script.clean_up
						tick = _script.tick
						draw_screen = _script.draw_screen
					}
					
					to_level = _level
					to_area = _area
					to_tag = _tag
					event_user(ThingEvents.CREATE)
				}
				
				exit
			}
		}
		
		with proControl {
			load_level = _level
			load_area = _area
			load_tag = _tag
			load_state = LoadStates.START
		}
	}
	
	static area_exists = function (_id) {
		gml_pragma("forceinline")
		
		return ds_map_exists(areas, _id)
	}
	
	/// @func count(type)
	/// @desc Returns the amount of the specified Thing and its children in all active areas.
	static count = function (_type) {
		var _count = 0
		var _players = global.players
		var i = 0
		
		repeat INPUT_MAX_PLAYERS {
			var _player = global.players[i++]
			
			if _player.status != PlayerStatus.ACTIVE or _player.level != self {
				continue
			}
			
			// TODO: Use bitmasking with area IDs so we don't add up the count
			//		 from the same area more than once.
			var _area = _player.area
			
			if _area != undefined {
				_count += _area.count(_type)
			}
		}
		
		return _count
	}
	
	static set_tick_scale = function (_scale) {
		global.tick_scale = _scale
	}
}