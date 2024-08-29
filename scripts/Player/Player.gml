function Player() constructor {
	slot = -1
	status = PlayerStatus.INACTIVE
	net = undefined
	
	// Area
	level = undefined
	area = undefined
	thing = noone
	camera = noone
	
	// State
	states = ds_map_create()
	
	// Input
	input = array_create(PlayerInputs.__SIZE, 0)
	input_previous = array_create(PlayerInputs.__SIZE, 0)
	__show_reconnect_caption = true
	
	static activate = function () {
		if status == PlayerStatus.INACTIVE {
			status = PlayerStatus.PENDING
			
			var _device = input_player_get_gamepad_type(slot)
			
			if _device == "unknown" {
				_device = "no controller"
			}
			
			++global.players_ready;
			show_caption($"[c_lime]{lexicon_text("hud.caption.player.ready", -~slot)} ({_device})")
			
			if global.demo_write {
				var _demo_buffer = global.demo_buffer
				
				if _demo_buffer != undefined {
					buffer_write(_demo_buffer, buffer_u32, global.demo_time)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.PLAYER_ACTIVATE)
					buffer_write(_demo_buffer, buffer_u8, slot)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.TERMINATE)
				}
			}
			
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
				show_caption($"[c_red]{lexicon_text("hud.caption.player.disconnect", -~slot)}")
			} else {
				--global.players_ready;
				show_caption($"[c_red]{lexicon_text("hud.caption.player.unready", -~slot)}")
			}
			
			status = PlayerStatus.INACTIVE
			
			if _in_area {
				set_area(undefined)
			}
			
			if global.demo_write {
				var _demo_buffer = global.demo_buffer
				
				if _demo_buffer != undefined {
					buffer_write(_demo_buffer, buffer_u32, global.demo_time)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.PLAYER_DEACTIVATE)
					buffer_write(_demo_buffer, buffer_u8, slot)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.TERMINATE)
				}
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
		
		var _flags = global.flags
		var _type = _flags[FlagGroups.LOCAL].get("player_class") ?? (_flags[FlagGroups.GLOBAL].get("player_class") ?? get_state("player_class"))
			
		if not is_string(_type) {
			show_error($"! Player.respawn: Got '{typeof(_type)}' as player class, expected string", true)
			
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
				_spawn = _spawns[global.rng_game.int(n - 1)]
			}
		}
		
		if instance_exists(_spawn) {
			var _player_pawn = noone
			
			global.last_player = slot
			
			with _spawn {
				_player_pawn = area.add(_type, x, y, z, angle, tag, special)
				
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
					input = _player.input
					input_previous = _player.input_previous
					catspeak_execute(player_create)
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
						catspeak_execute(player_respawned)
					}
				}
				
				return _player_pawn
			}
		}
		
		return noone
	}
	
	static set_area = function (_id, _tag = ThingTags.NONE) {
		/* Move away from the current area.
	
		   If this player was the master of the area, the smallest indexed
		   player will become the next one. Otherwise the master will be
		   undefined and the area will stop ticking. */
	   
		var _current_area = area
		
		if _current_area != undefined {
			var _active_things = _current_area.active_things
			var i = ds_list_size(_active_things)
			
			repeat i {
				var _thing = _active_things[| --i]
				
				_thing.player_left(_thing, self)
			}
			
			if instance_exists(thing) {
				thing.destroy(false)
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
					_newcomer.respawn()
					
					var i = ds_list_size(active_things)
					
					repeat i {
						var _thing = active_things[| --i]
						
						_thing.player_entered(_thing, _newcomer)
					}
					
					with level {
						if area_changed != undefined {
							catspeak_execute(area_changed, _newcomer, other)
						}
					}
					
					var _pawn = _newcomer.thing
					
					if instance_exists(_pawn) {
						var _entrances = find_tag(_tag)
						
						if array_length(_entrances) {
							_pawn.enter_from(_entrances[0])
						}
					}
				}
			}
		} else {
			area = undefined
		}
		
		return true
	}
	
	static get_state = function (_key) {
		return states[? _key]
	}
	
	static set_state = function (_key, _value) {
		states[? _key] = _value
		
		return true
	}
	
	static reset_state = function (_key) {
		var _default = global.default_states[? _key]
		
		states[? _key] = _default
		
		return _default
	}
	
	static clear_states = function () {
		ds_map_clear(states)
		states[? "invincible"] = false
		states[? "frozen"] = false
		states[? "hud"] = true
		
		var _default_states = global.default_states
		var _key = ds_map_find_first(_default_states)
		
		repeat ds_map_size(_default_states) {
			states[? _key] = _default_states[? _key]
			_key = ds_map_find_next(_default_states, _key)
		}
		
		return true
	}
	
	static is_local = function () {
		gml_pragma("forceinline")
		
		return true
	}
}