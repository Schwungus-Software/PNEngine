function Player() constructor {
	slot = noone
	status = PlayerStatus.INACTIVE
	
	// Netgame
	net = undefined
	
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
				player_force_area(self, undefined)
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
		
		player_force_area(self, _id)
		
		return true
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
	
	static __force_clear_states = function () {
		ds_map_clear(states)
		states[? "hp"] = 8
		states[? "coins"] = 0
		states[? "invincible"] = false
		states[? "frozen"] = false
	}
	
	static clear_states = function () {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active and master {
					var b = net_buffer_create(true, NetHeaders.HOST_RESET_PLAYER_STATES)
					
					buffer_write(b, buffer_u8, other.slot)
					send(SEND_OTHERS, b)
				} else {
					return false
				}
			}
		}
		
		__force_clear_states()
		
		return true
	}
	
	static is_local = function () {
		return net == undefined or net.local
	}
	
	__force_clear_states()
}