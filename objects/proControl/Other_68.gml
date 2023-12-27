if async_load[? "type"] == network_type_data {
	switch load_state {
		default: exit
		case LoadStates.NONE:
		case LoadStates.NETGAME_START:
		case LoadStates.NETGAME_FINISH:
		case LoadStates.NETGAME_LEVEL: break
	}
	
	var _ip = async_load[? "ip"]
	var _port = async_load[? "port"]
	
	var _buffer = async_load[? "buffer"]
	
	buffer_seek(_buffer, buffer_seek_start, 0)
	
	var _reliable = buffer_read(_buffer, buffer_u32)
	var _from = buffer_read(_buffer, buffer_u8)
	var _to = buffer_read(_buffer, buffer_u8)
	var _header = buffer_read(_buffer, buffer_u8)
	
	with global.netgame {
		if master {
			switch _header {
				case NetHeaders.CLIENT_CONNECT:
					var _key = _ip + ":" + string(_port)
					
					if ds_map_exists(clients, _key) {
						exit
					}
					
					if player_count >= MAX_NET_PLAYERS {
						var b = net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT)
						
						buffer_write(b, buffer_string, "NET_FULL")
						send_direct(_ip, _port, b)
						
						exit
					}
					
					if global.level.name != "lvlTitle" {
						var b = net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT)
						
						buffer_write(b, buffer_string, "NET_ACTIVE")
						send_direct(_ip, _port, b)
						
						exit
					}
					
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_CHECK_CLIENT))
					ds_map_add(clients, _key, undefined)
					time_source_start(ports_time_source)
					print($"proControl: Got valid connect request from client {_key}")
					
					exit
					
				case NetHeaders.CLIENT_VERIFY:
					var _key = _ip + ":" + string(_port)
					
					if ds_map_exists(clients, _key) and clients[? _key] != undefined {
						exit
					}
					
					if buffer_read(_buffer, buffer_string) != GM_version {
						var b = net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT)
						
						buffer_write(b, buffer_string, "NET_VERSION")
						send_direct(_ip, _port, b)
						
						exit
					}
					
					var _mods = global.mods
					var n = buffer_read(_buffer, buffer_u32)
					
					if n != ds_map_size(_mods) {
						var b = net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT)
						
						buffer_write(b, buffer_string, "NET_MODS")
						send_direct(_ip, _port, b)
						
						exit
					}
					
					var _mismatch = false
					
					repeat n {
						var _md5 = buffer_read(_buffer, buffer_string)
						
						if ds_map_exists(_mods, _md5) {
							_mismatch = true
							
							break
						}
					}
					
					if _mismatch {
						var b = net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT)
						
						buffer_write(b, buffer_string, "NET_MODS")
						send_direct(_ip, _port, b)
						
						break
					}
					
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_ALLOW_CLIENT))
					print($"proControl: Verified client {_key}")
					
					exit
					
				case NetHeaders.CLIENT_SEND_INFO:
					var _key = _ip + ":" + string(_port)
					
					if ds_map_exists(clients, _key) and clients[? _key] != undefined {
						exit
					}
					
					var b
					
					// Block the unfortunate new client if another one managed
					// to join before them
					if player_count >= MAX_NET_PLAYERS {
						b = net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT)
						buffer_write(b, buffer_string, "NET_FULL")
						send_direct(_ip, _port, b)
						
						break
					}
					
					// Send other clients' info to new client
					var _new_player = add_player(undefined, _ip, _port)
					
					b = net_buffer_create(false, NetHeaders.HOST_ADD_CLIENT)
					buffer_write(b, buffer_u8, _new_player.slot)
					buffer_write(b, buffer_u8, player_count - 1)
					
					var _players = global.players
					var j = 0
					
					repeat MAX_NET_PLAYERS {
						with _players[j] {
							if status == PlayerStatus.INACTIVE or net == _new_player {
								continue
							}
							
							print($"proControl: Sending info from Player {-~j}")
							buffer_write(b, buffer_u8, j)
							buffer_write(b, buffer_u8, status)
							buffer_write(b, buffer_string, net.name)
						}
						
						++j
					}
					
					send_direct(_ip, _port, b)
					
					// Send new client info to everyone
					var _slot = _new_player.slot
					var _name = buffer_read(_buffer, buffer_string)
					
					_new_player.name = _name
					b = net_buffer_create(true, NetHeaders.PLAYER_JOINED)
					buffer_write(b, buffer_u8, _slot)
					buffer_write(b, buffer_string, _name)
					send(SEND_OTHERS, b)
					game_update_status()
					
					// Debug
					var _pind = -~_slot
					
					print($"proControl: Assigned client '{_name}' to player {_pind}")
					net_chat(lexicon_text("netgame.player_joined", _name), C_PN_YELLOW)
					
					exit
					
				case NetHeaders.CLIENT_DISCONNECT:
					var _key = _ip + ":" + string(_port)
					
					if not ds_map_exists(clients, _key) {
						exit
					}
					
					var _other = clients[? _key]
					
					if _other == undefined {
						ds_map_delete(clients, _key)
						
						exit
					}
					
					var b = net_buffer_create(true, NetHeaders.PLAYER_LEFT)
					
					with _other {
						buffer_write(b, buffer_u8, slot)
						net_chat(lexicon_text("netgame.player_left", name), C_PN_YELLOW)
						destroy()
					}
					
					send(SEND_OTHERS, b)
					game_update_status()
					
					exit
				
				case NetHeaders.CLIENT_PONG:
					var _client = clients[? _ip + ":" + string(_port)]
					
					if _client != undefined {
						_client.ping = 0
					}
					
					exit
					
				case NetHeaders.HOST_CHECK_CLIENT:
				case NetHeaders.HOST_ALLOW_CLIENT:
				case NetHeaders.HOST_BLOCK_CLIENT:
				case NetHeaders.HOST_ADD_CLIENT:
				case NetHeaders.HOST_DISCONNECT:
				case NetHeaders.HOST_PING:
				case NetHeaders.PLAYER_LEFT:
				case NetHeaders.HOST_LEVEL:
				case NetHeaders.HOST_AREA:
				case NetHeaders.HOST_THING:
				case NetHeaders.HOST_DESTROY_THING:
				case NetHeaders.HOST_PLAYER_STATE:
				case NetHeaders.HOST_FLAG:
				case NetHeaders.HOST_RESET_FLAGS:
				case NetHeaders.HOST_RESET_PLAYER_STATES:
					exit
			}
		}
		
		if _to == local_slot {
			if _reliable > 0 {
				var _net = players[| _from]
				
				if _net == undefined {
					print($"! proControl: Got invalid ROM from player {-~_from} (index {_reliable})")
				} else {
					var _skip = false
					
					with _net {
						if _reliable <= reliable_received {
							_skip = true
							print($"! proControl: Got outdated ROM from player {-~_from} (index {_reliable})")
						} else {
							reliable_received = _reliable
							print($"proControl: Got ROM {_reliable} from player {-~_from}")
						}
					}
					
					var b = net_buffer_create(false, NetHeaders.ACK)
					
					buffer_write(b, buffer_u32, _reliable)
					send(_from, b)
					
					if _skip {
						exit
					}
				}
			}
		} else {
			if master {
				send(_to, _buffer, undefined, true, false)
			}
			
			exit
		}
		
		switch _header {
			case NetHeaders.ACK:
				var _net = players[| _from]
				
				if _net == undefined {
					break
				}
				
				var _index = buffer_read(_buffer, buffer_u32)
				
				with _net {
					if not ds_list_empty(reliable) {
						var b = reliable[| 0]
						
						buffer_seek(b, buffer_seek_start, 0)
						
						var _compare = buffer_read(b, buffer_u32)
						
						if _compare == _index {
							if proControl.load_state == LoadStates.NETGAME_LEVEL {
								// Skip from and to
								buffer_read(b, buffer_u8)
								buffer_read(b, buffer_u8)
								
								var _compare_header = buffer_read(b, buffer_u8)
								
								if _compare_header == NetHeaders.HOST_LEVEL {
									print($"proControl: Got ready from player {-~_from}")
									ready = true
								}
							}
							
							buffer_delete(b)
							ds_list_delete(reliable, 0)
							print($"proControl: Got ACK {_index} from player {-~_from}")
						}
					}
				}
			break
			
			case NetHeaders.HOST_CHECK_CLIENT:
				if _ip != ip or _port != port or _from != 0 {
					break
				}
				
				var b = net_buffer_create(false, NetHeaders.CLIENT_VERIFY)
				
				buffer_write(b, buffer_string, GM_version)
				
				var _mods = global.mods
				var n = ds_map_size(_mods)
				
				buffer_write(b, buffer_u32, n)
				
				var _key = ds_map_find_first(_mods)
				
				repeat n {
					buffer_write(b, buffer_string, _mods[? _key].md5)
					_key = ds_map_find_next(_mods, _key)
				}
				
				send_direct(_ip, _port, b)
				print("proControl: Found connection from server")
			break
			
			case NetHeaders.HOST_BLOCK_CLIENT:
				if _ip != ip or _port != port or _from != 0 {
					break
				}
				
				disconnect()
				code = buffer_read(_buffer, buffer_string)
				
				if connect_fail_callback != undefined {
					connect_fail_callback()
				}
			break
			
			case NetHeaders.HOST_ALLOW_CLIENT:
				if _ip != ip or _port != port or _from != 0 {
					break
				}
				
				time_source_stop(connect_time_source)
				time_source_start(timeout_time_source)
				
				var b = net_buffer_create(false, NetHeaders.CLIENT_SEND_INFO)
				
				buffer_write(b, buffer_string, global.config.name)
				send_direct(_ip, _port, b)
			break
			
			case NetHeaders.HOST_ADD_CLIENT:
				if _ip != ip or _port != port or _from != 0 {
					break
				}
				
				time_source_stop(connect_time_source)
				active = true
				
				var _players = global.players
				
				array_foreach(_players, function (_element, _index) {
					if _index != 0 {
						_element.deactivate()
					}
				})
				
				local_slot = buffer_read(_buffer, buffer_u8)
				print($"proControl: Assigned as Player {-~local_slot}")
				
				var _local = add_player(local_slot, "127.0.0.1", 0)
				
				with _local {
					name = global.config.name
					local = true
				}
				
				repeat buffer_read(_buffer, buffer_u8) {
					var _slot = buffer_read(_buffer, buffer_u8)
					
					print($"Getting info from Player {-~_slot}")
					
					var _other = add_player(_slot, _slot ? "127.0.0.1" : _ip, _slot ? 0 : _port)
					
					with _other {
						player.status = buffer_read(_buffer, buffer_u8)
						name = buffer_read(_buffer, buffer_string)
					}
				}
				
				// Iterate through all players for ready and active counts
				global.players_ready = 0
				global.players_active = 0
				
				array_foreach(_players, function (_element, _index) {
					switch _element.status {
						case PlayerStatus.PENDING:
							++global.players_ready
						break
						
						case PlayerStatus.ACTIVE:
							++global.players_active
						break
					}
				})
				
				print($"Total players: {player_count} ({global.players_ready} ready, {global.players_active} active)")
				
				if connect_success_callback != undefined {
					connect_success_callback()
				}
				
				was_connected_before = true
			break
			
			case NetHeaders.PLAYER_JOINED:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				var _slot = buffer_read(_buffer, buffer_u8)
				
				if _slot == local_slot {
					break
				}
				
				with add_player(_slot, "127.0.0.1", 0) {
					name = buffer_read(_buffer, buffer_string)
					net_chat(lexicon_text("netgame.player_joined", name), C_PN_YELLOW)
				}
				
				game_update_status()
			break
			
			case NetHeaders.HOST_DISCONNECT:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				/*disconnect()
				code = "NET_CLOSE"
				
				if connect_fail_callback != undefined {
					connect_fail_callback()
				}
				
				game_update_status()*/
				cmd_disconnect("")
				show_caption($"[c_red]{lexicon_text("netgame.code.NET_CLOSE")}")
			break
			
			case NetHeaders.PLAYER_LEFT:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				var _slot = buffer_read(_buffer, buffer_u8)
				
				if _slot == local_slot {
					disconnect()
					code = "NET_KICK"
					was_connected_before = true
					
					if connect_fail_callback != undefined {
						connect_fail_callback()
					}
					
					was_connected_before = false
					
					break
				}
				
				var _other = players[| _slot]
				
				if _other != undefined {
					with _other {
						destroy()
						net_chat(lexicon_text("netgame.player_left", name), C_PN_YELLOW)
					}
				}
				
				game_update_status()
			break
			
			case NetHeaders.HOST_PING:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				time_source_reset(timeout_time_source)
				time_source_start(timeout_time_source)
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.CLIENT_PONG))
			break
			
			case NetHeaders.CHAT:
				if _from == _to {
					break
				}
				
				var _net = players[| _from]
				
				if _net == undefined {
					print($"! proControl: Got chat message from invalid player {-~_from} ({_ip}:{_port})")
					
					break
				}
				
				net_chat($"{_net.name}: {buffer_read(_buffer, buffer_string)}")
				global.ui_sounds.play(chat_sound)
			break
			
			case NetHeaders.INPUT:
				if _from == local_slot {
					break
				}
				
				var _net = players[| _from]
				
				if _net == undefined {
					print($"! proControl: Got input from invalid player {-~_from} ({_ip}:{_port})")
					
					break
				}
				
				with _net.player {
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_s8))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_s8))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_bool))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_s8))
					ds_queue_enqueue(input_queue, buffer_read(_buffer, buffer_s8))
				}
			break
			
			case NetHeaders.HOST_LEVEL:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				var _level = buffer_read(_buffer, buffer_string)
				var _area = buffer_read(_buffer, buffer_u32)
				var _tag = buffer_read(_buffer, buffer_s32)
				
				level_force_goto(_level, _area, _tag, false)
			break
			
			case NetHeaders.HOST_AREA:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				player_force_area(global.players[buffer_read(_buffer, buffer_u8)], buffer_read(_buffer, buffer_u8))
			break
			
			case NetHeaders.HOST_THING:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				var _level = global.level
				var _syncables = _level.syncables
				var _sync_id = buffer_read(_buffer, buffer_u16)
				var _area_id = buffer_read(_buffer, buffer_u32)
				var _name = buffer_read(_buffer, buffer_string)
				var _variables = buffer_read(_buffer, buffer_u8)
				var _thing = noone
				
				if _sync_id < ds_grid_width(_syncables) {
					_thing = _syncables[# _sync_id, 0]
					
					if instance_exists(_thing) {
						with _thing {
							if area.slot != _area_id {
								instance_destroy(id, false)
								
								break
							}
							
							if thing_script != undefined {
								if thing_script.name != _name {
									instance_destroy(id, false)
								}
							} else if object_get_name(object_index) != _name {
								instance_destroy(id, false)
							}
						}
					}
				}
				
				if not instance_exists(_thing) {
					var _area_thing = _level.area_things[| _sync_id]
					var _area
					
					if _area_thing == undefined or not is_instanceof(_area_thing, AreaThing) {
						_area_thing = undefined
						_area = _level.areas[? _area_id]
					} else {
						_area = _area_thing.area
					}
					
					if _area == undefined {
						break
					}
					
					var _idx = asset_get_index(_name)
					
					if object_exists(_idx) {
						if not object_is_ancestor(_idx, Thing) {
							print($"! proControl: Tried to sync non-Thing '{_name}'")
							
							break
						}
						
						if string_starts_with(_name, "pro") {
							print($"! proControl: Tried to sync protected Thing '{_name}'")
							
							break
						}
						
						_thing = instance_create_depth(0, 0, 0, _idx)
					}
					
					if not instance_exists(_thing) {
						var _thing_script = global.scripts.get(_name)
						
						if _thing_script == undefined {
							print($"! proControl: Tried to sync unknown Thing '{_name}'")
							
							break
						}
						
						_thing = instance_create_depth(0, 0, 0, _thing_script.internal_parent)
						
						with _thing {
							thing_script = _thing_script
							create = _thing_script.create
							on_destroy = _thing_script.on_destroy
							clean_up = _thing_script.clean_up
							tick = _thing_script.tick
							draw = _thing_script.draw
							draw_screen = _thing_script.draw_screen
							draw_gui = _thing_script.draw_gui
						}
					}
					
					with _thing {
						level = _level
						area = _area
						area_thing = _area_thing
						
						if area_thing != undefined {
							x = area_thing.x
							y = area_thing.y
							z = area_thing.z
							x_start = x
							y_start = y
							z_start = z
							x_previous = x
							y_previous = y
							z_previous = z
							angle = area_thing.angle
							tag = area_thing.tag
							special = area_thing.special
							f_persistent = area_thing.persistent
							f_disposable = area_thing.disposable
						}
						
						f_new = true
						event_user(ThingEvents.CREATE)
						f_created = true
						sync_id = _sync_id
						
						while ds_grid_width(_syncables) <= _sync_id {
							var n = ds_grid_width(_syncables)
							
							ds_grid_resize(_syncables, -~n, 2)
							_syncables[# n, 0] = noone
							_syncables[# n, 1] = noone
						}
						
						_syncables[# _sync_id, 0] = _thing
					}
					
					if instance_exists(_thing) {
						with _area_thing {
							if thing != _thing {
								if instance_exists(thing) {
									instance_destroy(thing, false)
								}
								
								thing = _thing
							}
						}
						
						ds_list_add(_area.active_things, _thing)
					}
				}
				
				if instance_exists(_thing) {
					with _thing {
						repeat _variables {
							var _key = buffer_read(_buffer, buffer_u8)
							var _value = buffer_read_dynamic(_buffer)
							var _netvar = net_variables[| _key]
							
							if _netvar != undefined {
								with _netvar {
									if read != undefined {
										if is_catspeak(read) {
											read.setSelf(scope)
										}
										
										read(_value)
									} else {
										struct_set_from_hash(scope, hash, _value)
									}
								}
							}
						}
					}
				}
			break
			
			case NetHeaders.HOST_DESTROY_THING:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				var _thing = global.level.syncables[# buffer_read(_buffer, buffer_u16), 0]
				
				if _thing != undefined {
					instance_destroy(_thing, buffer_read(_buffer, buffer_bool))
				}
			break
			
			case NetHeaders.HOST_PLAYER_STATE:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				with global.players[buffer_read(_buffer, buffer_u8)] {
					var _key = buffer_read(_buffer, buffer_string)
					var _value = buffer_read_dynamic(_buffer)
					
					states[? _key] = _value
				}
			break
			
			case NetHeaders.HOST_FLAG:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				with global.flags[buffer_read(_buffer, buffer_u8)] {
					var _key = buffer_read(_buffer, buffer_string)
					var _value = buffer_read_dynamic(_buffer)
					
					flags[? _key] = _value
				}
			break
			
			case NetHeaders.HOST_RESET_PLAYER_STATES:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				player_force_clear_states(global.players[buffer_read(_buffer, buffer_u8)])
			break
			
			case NetHeaders.HOST_RESET_FLAGS:
				if _ip != ip or _port != port or _from != 0 or _from == _to {
					break
				}
				
				flags_force_clear(global.flags[buffer_read(_buffer, buffer_u8)])
			break
			
			default:
				print($"! proControl: Unknown header from player {-~_from} ({_ip}:{_port})")
		}
	}
}