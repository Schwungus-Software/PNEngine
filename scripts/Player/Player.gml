function Player() constructor {
	slot = noone
	status = PlayerStatus.INACTIVE
	
	// Netgame
	net_player = undefined
	
	// Area
	level = undefined
	area = undefined
	thing = noone
	camera = noone
	
	// State
	states = ds_map_create()
	
	// Input
	input = array_create(PlayerInputs.__SIZE)
	input_previous = array_create(PlayerInputs.__SIZE)
	input_queue = ds_queue_create()
	__show_reconnect_caption = true
	
	static activate = function () {
		if status == PlayerStatus.INACTIVE {
			status = PlayerStatus.PENDING
			
			var _device = input_player_get_gamepad_type(slot)
			
			if _device == "unknown" {
				_device = "no controller"
			}
			
			++global.players_ready;
			show_caption($"[c_lime]Player {-~slot} readied! ({_device})")
			
			return true
		}
		
		return false
	}
	
	static deactivate = function () {
		if status != PlayerStatus.INACTIVE {
			var _in_area = false
			
			if status == PlayerStatus.ACTIVE {
				if global.players_active <= 1 {
					return false
				}
				
				--global.players_active;
				
				if instance_exists(thing) {
					thing.destroy()
				}
				
				_in_area = true
				show_caption($"[c_red]Player {-~slot} disconnected!")
			} else {
				--global.players_ready;
				show_caption($"[c_red]Player {-~slot} unreadied!")
			}
			
			ds_queue_clear(input_queue)
			status = PlayerStatus.INACTIVE
			
			if _in_area {
				__force_area(undefined)
			}
			
			return true
		}
		
		return false
	}
	
	static set_area = function (_id) {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active and master {
					var b = net_buffer_create(true, NetHeaders.HOST_AREA)
				
					buffer_write(b, buffer_u8, other.slot)
					buffer_write(b, buffer_u32, other.area.slot)
					_netgame.send(SEND_OTHERS, b)
				} else {
					return false
				}
			}
		}
		
		__force_area(_id)
		
		return true
	}
	
	static __force_area = function (_id) {
		/* Move away from the current area.
		
		   If this player was the master of the area, the smallest indexed
		   player will become the next one. Otherwise the master will be
		   undefined and the area will stop ticking. */
		var _current_area = area
		
		if _current_area != undefined {
			var _active_things = _current_area.active_things
			var i = ds_list_size(_active_things)
			
			repeat i {
				with _active_things[| --i] {
					player_left(other)
				}
			}
			
			var _players_in_area = _current_area.players
			
			ds_list_delete(_players_in_area, ds_list_find_index(_players_in_area, self))
			
			if _current_area.master == self {
				var _new_master = false
				
				i = 0
				
				repeat ds_list_size(_players_in_area) {
					var _player = _players_in_area[| i]
					
					with _player {
						if status == PlayerStatus.ACTIVE {
							_current_area.master = _player
							_new_master = true
						}
					}
					
					++i
					
					if _new_master {
						break
					}
				}
			}
			
			_current_area.deactivate()
		}
		
		/* Move to the new area.
		   If this area is inactive, the first player to enter it will become
		   responsible for ticking. */
		if level != undefined {
			area = level.areas[? _id]
			
			if area != undefined {
				with area {
					var _newcomer = other
					
					master ??= _newcomer
					ds_list_add(players, _newcomer)
					activate()
					
					var i = ds_list_size(active_things)
					
					repeat i {
						active_things[| --i].player_entered(_newcomer)
					}
					
					with level {
						if area_changed != undefined {
							area_changed(_newcomer, other)
						}
					}
				}
			}
		} else {
			area = undefined
		}
	}
	
	static get_state = function (_key) {
		return states[? _key]
	}
	
	static set_state = function (_key, _value) {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active and master {
					var b = net_buffer_create(true, NetHeaders.HOST_PLAYER_STATE)
					
					buffer_write(b, buffer_u8, other.slot)
					buffer_write(b, buffer_string, _key)
					buffer_write_dynamic(b, _value)
					send(SEND_OTHERS, b)
				} else {
					return false
				}
			}
		}
		
		states[? _key] = _value
		
		return true
	}
	
	static clear_states = function () {
		ds_map_clear(states)
		states[? "hp"] = 8
		states[? "coins"] = 0
		states[? "invincible"] = false
		states[? "frozen"] = false
	}
	
	clear_states()
}