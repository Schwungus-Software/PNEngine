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
		
		print("! Player.activate: Player is already ready/active")
		
		return false
	}
	
	static deactivate = function () {
		if status != PlayerStatus.INACTIVE {
			var _in_area = false
			
			if status == PlayerStatus.ACTIVE {
				if global.players_active <= 1 {
					print("! Player.deactivate: Cannot deactivate with one player remaining")
					
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
		
		print("! Player.deactivate: Player is already inactive")
		
		return false
	}
	
	static respawn = function () {
		if status != PlayerStatus.ACTIVE or area == undefined {
			return noone
		}
		
		var _netgame = global.netgame
		
		if _netgame != undefined and not _netgame.master {
			return noone
		}
		
		var _type = global.flags[0].get("player_class")
			
		if _type == undefined {
			return noone
		}
		
		var _spawn = noone
		
		// Pick a spawn furthest from all players.
		var _pawns = area.find_tag(ThingTags.PLAYERS)
		var n = array_length(_pawns)
		
		if n {
			var _x = 0
			var _y = 0
			var _z = 0
			var i = 0
			
			repeat n {
				with _pawns[i++] {
					_x += x
					_y += y
					_z += z
				}
			}
			
			var _inv = 1 / n
			
			_x *= _inv
			_y *= _inv
			_z *= _inv
			_spawn = area.furthest(_x, _y, _z, PlayerSpawn)
		} else {
			// There are no players in this level, pick a random spawn.
			var _spawns = area.find_tag(ThingTags.PLAYER_SPAWNS)
			
			n = array_length(_spawns)
			
			if n {
				_spawn = _spawns[RNG.irandom(n - 1)]
			}
		}
		
		if instance_exists(_spawn) {
			var _player_pawn = noone
			
			global.last_player = slot
			
			with _spawn {
				var _player_pawn = area.add(_type, x, y, z, angle, tag, special)
				
				if not instance_exists(_player_pawn) {
					return noone
				}
				
				var _player = other
				
				with _player_pawn {
					if not is_ancestor(PlayerPawn) {
						destroy(false)
						
						return noone
					}
					
					player = _player
					states = _player.states
					input = _player.input
					input_previous = _player.input_previous
				}
			}
			
			if instance_exists(_player_pawn) {
				var _respawned = false
				
				if instance_exists(thing) {
					instance_destroy(thing, false)
					_respawned = true
				}
				
				thing = _player_pawn
				
				if instance_exists(camera) {
					instance_destroy(camera, false)
				}
				
				camera = _player_pawn.camera
				input[PlayerInputs.FORCE_LEFT_RIGHT] = _player_pawn.angle
				input[PlayerInputs.FORCE_UP_DOWN] = -15
				
				if _respawned {
					with _player_pawn {
						if is_catspeak(player_respawned) {
							player_respawned.setSelf(_player_pawn)
						}
						
						player_respawned()
					}
				}
				
				return _player_pawn
			}
		}
		
		return noone
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
		
		player_force_clear_states(self)
		
		return true
	}
	
	static is_local = function () {
		gml_pragma("forceinline")
		
		return net == undefined or net.local
	}
	
	player_force_clear_states(self)
}