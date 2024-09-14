#macro CLIENT_CHECK_HOST if _ip != ip or _port != port or _from != 0 { break }
#macro CLIENT_CHECK_DIRECT if _ip != ip or _port != port { break }
#macro CLIENT_CHECK_SENDER if _ip != ip or _port != port or _from != 0 or _from == _to { break }

if async_load[? "type"] != network_type_data {
	exit
}

switch load_state {
	case LoadStates.NONE:
	case LoadStates.CONNECT:
	case LoadStates.CLIENT_WAIT:
	case LoadStates.HOST_READY:
	case LoadStates.CLIENT_READY: break
	default: exit
}

var _ip = async_load[? "ip"]
var _port = async_load[? "port"]
var _buffer = async_load[? "buffer"]

buffer_seek(_buffer, buffer_seek_start, 0) // ???

var _reliable = buffer_read(_buffer, buffer_u32)
var _from = buffer_read(_buffer, buffer_u8)
var _to = buffer_read(_buffer, buffer_u8)
var _header = buffer_read(_buffer, buffer_u8)
var _netgame = global.netgame

with _netgame {
	if master {
		switch _header {
			case NetHeaders.CLIENT_CONNECT: {
				var _key = $"{_ip}:{_port}"
				
				// Ignore connect requests from already existing clients.
				if ds_map_exists(clients, _key) {
					exit
				}
				
				// Is the server full?
				if player_count >= INPUT_MAX_PLAYERS {
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_FULL"))
						
					exit
				}
				
				// Is the game not active?
				if global.level.name != "lvlTitle" {
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_ACTIVE"))
						
					exit
				}
				
				// Request more information from client.
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_CHECK_CLIENT))
				ds_map_add(clients, _key, undefined)
				time_source_start(ports_time_source)
				print($"proControl: Got valid connect request from client {_key}")
				
				exit
			}
					
			case NetHeaders.CLIENT_VERIFY: {
				var _key = $"{_ip}:{_port}"
				
				// Ignore verification from already existing clients.
				if ds_map_exists(clients, _key) and clients[? _key] != undefined {
					exit
				}
				
				// Do PNEngine versions match?
				var _version = buffer_read(_buffer, buffer_string)
				
				if _version != GM_version {
					print($"! proControl: Client {_key} version doesn't match ({_version} =/= {GM_version}), blocking")
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_VERSION"))
					
					exit
				}
				
				// Do all active mods match?
				var _mods = global.mods
				var n = buffer_read(_buffer, buffer_u32)
				var _target_amount = ds_map_size(_mods)
				
				// 1. Mod amount
				if n != _target_amount {
					print($"! proControl: Client {_key} mod amount doesn't match ({n} =/= {_target_amount}), blocking")
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_MODS"))
						
					exit
				}
				
				// 2. Mod hashes
				var _mismatch = true
					
				repeat n {
					_mismatch = true
					
					var _md5 = buffer_read(_buffer, buffer_string)
					var _kk = ds_map_find_first(_mods)
					
					repeat _target_amount {
						if _mods[? _kk].md5 == _md5 {
							_mismatch = false
							
							break
						}
						
						_kk = ds_map_find_next(_mods, _kk)
					}
					
					if _mismatch {
						print($"! proControl: Unknown mod detected! {_md5}")
						
						break
					}
				}
					
				if _mismatch {
					print($"! proControl: Client {_key} mod hashes don't match, blocking")
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_MODS"))
					
					exit
				}
				
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_ALLOW_CLIENT))
				print($"proControl: Verified client {_key}")
				
				exit
			}
				
			case NetHeaders.CLIENT_SEND_INFO: {
				var _key = $"{_ip}:{_port}"
				
				// Ignore information from already existing clients.
				if ds_map_exists(clients, _key) and clients[? _key] != undefined {
					exit
				}
				
				// Block the unfortunate new client if another one managed to
				// join before them.
				if player_count >= INPUT_MAX_PLAYERS {
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_FULL"))
					
					exit
				}
				
				// Send other clients' info to new client.
				var _new_player = add_player(undefined, _ip, _port)
				
				b = net_buffer_create(false, NetHeaders.HOST_ADD_CLIENT, buffer_u8, _new_player.slot, buffer_u8, player_count - 1)
				
				var _players = global.players
				var j = 0
					
				repeat INPUT_MAX_PLAYERS {
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
				send(SEND_OTHERS, net_buffer_create(true, NetHeaders.PLAYER_JOINED, buffer_u8, _slot, buffer_string, _name))
				game_update_status()
				print($"proControl: Assigned client '{_name}' to player {-~_slot}")
					
				exit
			}
					
			case NetHeaders.CLIENT_DISCONNECT: {
				var _key = $"{_ip}:{_port}"
				
				// Ignore ghost clients.
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
					print($"proControl: Client '{name}' disconnected")
					destroy()
				}
					
				send(SEND_OTHERS, b)
				game_update_status()
				
				exit
			}
				
			case NetHeaders.CLIENT_PONG: {
				var _client = clients[? $"{_ip}:{_port}"]
				
				if _client != undefined {
					_client.ping = 0
				}
				
				exit
			}
			
			// Ignore mischievous packets.
			case NetHeaders.HOST_CHECK_CLIENT:
			case NetHeaders.HOST_ALLOW_CLIENT:
			case NetHeaders.HOST_BLOCK_CLIENT:
			case NetHeaders.HOST_ADD_CLIENT:
			case NetHeaders.HOST_DISCONNECT:
			case NetHeaders.HOST_PING:
			case NetHeaders.PLAYER_LEFT:
			case NetHeaders.HOST_LEVEL:
			case NetHeaders.HOST_LEVEL_READY:
			case NetHeaders.HOST_STATES_FLAGS:
			case NetHeaders.HOST_TICK: exit
		}
	}
	
	if _to == local_slot {
		if _reliable > 0 {
			var _net = players[| _from]
				
			if _net == undefined {
				print($"! proControl: Got invalid ROM from player {-~_from} (index {_reliable})")
				
				exit
			} else {
				var _skip = false
				
				if _reliable <= _net.reliable_received {
					_skip = true
				} else {
					_net.reliable_received = _reliable
				}
				
				send(_from, net_buffer_create(false, NetHeaders.ACK, buffer_u32, _reliable))
				
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
		case NetHeaders.ACK: {
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
						if _netgame.master {
							// Skip from and to
							buffer_read(b, buffer_u8)
							buffer_read(b, buffer_u8)
								
							var _compare_header = buffer_read(b, buffer_u8)
							
							if _compare_header == NetHeaders.HOST_TICK and not tick_acked {
								tick_acked = true;
								++_netgame.ack_count
							}
						}
						
						buffer_delete(b)
						ds_list_delete(reliable, 0)
					}
				}
			}
			
			break
		}
			
		case NetHeaders.HOST_CHECK_CLIENT: {
			CLIENT_CHECK_HOST
			
			var b = net_buffer_create(false, NetHeaders.CLIENT_VERIFY, buffer_string, GM_version)
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
		}
			
		case NetHeaders.HOST_BLOCK_CLIENT: {
			CLIENT_CHECK_HOST
			
			disconnect()
			code = buffer_read(_buffer, buffer_string)
			
			if connect_fail_callback != undefined {
				connect_fail_callback()
			}
			
			destroy()
			
			break
		}
		
		case NetHeaders.HOST_ALLOW_CLIENT: {
			CLIENT_CHECK_HOST
			
			time_source_stop(connect_time_source)
			time_source_start(timeout_time_source)
			send_direct(_ip, _port, net_buffer_create(false, NetHeaders.CLIENT_SEND_INFO, buffer_string, global.config.name))
			
			break
		}
			
		case NetHeaders.HOST_ADD_CLIENT: {
			CLIENT_CHECK_HOST
			
			time_source_stop(connect_time_source)
			active = true
			local_slot = buffer_read(_buffer, buffer_u8)
			print($"proControl: Assigned as Player {-~local_slot}")
			
			var _local = add_player(local_slot, "127.0.0.1", 0)
			
			_local.name = global.config.name
			_local.local = true
			
			repeat buffer_read(_buffer, buffer_u8) {
				var _slot = buffer_read(_buffer, buffer_u8)
				
				print($"Getting info from Player {-~_slot}")
				
				var _other = add_player(_slot, _slot ? "127.0.0.1" : _ip, _slot ? 0 : _port)
				
				_other.player.status = buffer_read(_buffer, buffer_u8)
				_other.name = buffer_read(_buffer, buffer_string)
			}
			
			// Iterate through all players for ready and active counts
			global.players_ready = 0
			global.players_active = 0
			
			var _players = global.players
			var i = 0
			
			repeat INPUT_MAX_PLAYERS {
				switch _players[i++].status {
					case PlayerStatus.PENDING:
						++global.players_ready
					break
						
					case PlayerStatus.ACTIVE:
						++global.players_active
					break
				}
			}
				
			print($"Total players: {player_count} ({global.players_ready} ready, {global.players_active} active)")
				
			if connect_success_callback != undefined {
				connect_success_callback()
			}
				
			was_connected_before = true
			
			break
		}
		
		case NetHeaders.PLAYER_JOINED: {
			CLIENT_CHECK_SENDER
				
			var _slot = buffer_read(_buffer, buffer_u8)
				
			if _slot == local_slot {
				break
			}
				
			with add_player(_slot, "127.0.0.1", 0) {
				name = buffer_read(_buffer, buffer_string)
				print($"proControl: Client '{name}' joined")
			}
				
			game_update_status()
			
			break
		}
		
		case NetHeaders.HOST_DISCONNECT: {
			CLIENT_CHECK_SENDER
			cmd_disconnect("")
			show_caption($"[c_red]Host disconnected")
			
			break
		}
			
		case NetHeaders.PLAYER_LEFT: {
			CLIENT_CHECK_SENDER
			
			var _slot = buffer_read(_buffer, buffer_u8)
				
			if _slot == local_slot {
				disconnect()
				code = "NET_KICK"
				was_connected_before = true
					
				if connect_fail_callback != undefined {
					connect_fail_callback()
				}
					
				was_connected_before = false
				destroy()
					
				break
			}
				
			var _other = players[| _slot]
				
			if _other != undefined {
				print($"proControl: Client '{_other.name}' left")
				_other.destroy()
			}
				
			game_update_status()
			
			break
		}
			
		case NetHeaders.HOST_PING: {
			CLIENT_CHECK_SENDER
			time_source_reset(timeout_time_source)
			time_source_start(timeout_time_source)
			send_direct(_ip, _port, net_buffer_create(false, NetHeaders.CLIENT_PONG))
			
			break
		}
		
		case NetHeaders.HOST_LEVEL: {
			CLIENT_CHECK_SENDER
			
			var _level = buffer_read(_buffer, buffer_string)
			var _area = buffer_read(_buffer, buffer_u32)
			var _tag = buffer_read(_buffer, buffer_s32)
			
			with proControl {
				load_level = _level
				load_area = _area
				load_tag = _tag
				load_state = LoadStates.START
			}
			
			break
		}
		
		case NetHeaders.CLIENT_LEVEL_READY: {
			if not master {
				break
			}
			
			var _player = players[| _from]
			
			if _player != undefined {
				_player.ready = true
			}
			
			break
		}
		
		case NetHeaders.HOST_LEVEL_READY: {
			CLIENT_CHECK_SENDER
			
			if proControl.load_state == LoadStates.CLIENT_READY {
				proControl.load_state = LoadStates.NONE
			}
			
			break
		}
		
		case NetHeaders.HOST_STATES_FLAGS: {
			CLIENT_CHECK_SENDER
			
			var _players = global.players
			var n = buffer_read(_buffer, buffer_u8)
			
			repeat n {
				var _slot = buffer_read(_buffer, buffer_u8)
				
				_players[_slot].read_states(_buffer)
			}
			
			global.flags[FlagGroups.GLOBAL].read(_buffer)
			
			break
		}
		
		case NetHeaders.CLIENT_INPUT: {
			if not master {
				break
			}
			
			var _player = players[| _from]
			
			if _player != undefined {
				var _input_up_down = buffer_read(_buffer, buffer_s8)
				var _input_left_right = buffer_read(_buffer, buffer_s8)
				
				var _input_flags = buffer_read(_buffer, buffer_u8)
				var _input_jump = _input_flags & PIFlags.JUMP
				var _input_interact = _input_flags & PIFlags.INTERACT
				var _input_attack = _input_flags & PIFlags.ATTACK
				var _input_inventory_up = _input_flags & PIFlags.INVENTORY_UP
				var _input_inventory_left = _input_flags & PIFlags.INVENTORY_LEFT
				var _input_inventory_down = _input_flags & PIFlags.INVENTORY_DOWN
				var _input_inventory_right = _input_flags & PIFlags.INVENTORY_RIGHT
				var _input_aim = _input_flags & PIFlags.AIM
				
				var _input_aim_up_down = buffer_read(_buffer, buffer_s16)
				var _input_aim_left_right = buffer_read(_buffer, buffer_s16)
				
				ds_queue_enqueue(_player.input_queue,
					_input_up_down,
					_input_left_right,
					_input_jump,
					_input_interact,
					_input_attack,
					_input_inventory_up,
					_input_inventory_left,
					_input_inventory_down,
					_input_inventory_right,
					_input_aim,
					_input_aim_up_down,
					_input_aim_left_right
				)
			}
		}
		
		case NetHeaders.HOST_TICK: {
			CLIENT_CHECK_SENDER
			
			var n = buffer_read(_buffer, buffer_u8)
			
			ds_queue_enqueue(tick_queue, n)
			
			repeat n {
				var _slot = buffer_read(_buffer, buffer_u8)
				var _input_up_down = buffer_read(_buffer, buffer_s8)
				var _input_left_right = buffer_read(_buffer, buffer_s8)
				
				var _input_flags = buffer_read(_buffer, buffer_u8)
				var _input_jump = _input_flags & PIFlags.JUMP
				var _input_interact = _input_flags & PIFlags.INTERACT
				var _input_attack = _input_flags & PIFlags.ATTACK
				var _input_inventory_up = _input_flags & PIFlags.INVENTORY_UP
				var _input_inventory_left = _input_flags & PIFlags.INVENTORY_LEFT
				var _input_inventory_down = _input_flags & PIFlags.INVENTORY_DOWN
				var _input_inventory_right = _input_flags & PIFlags.INVENTORY_RIGHT
				var _input_aim = _input_flags & PIFlags.AIM
				
				var _input_aim_up_down = buffer_read(_buffer, buffer_s16)
				var _input_aim_left_right = buffer_read(_buffer, buffer_s16)
				
				ds_queue_enqueue(tick_queue,
					_slot,
					_input_up_down,
					_input_left_right,
					_input_jump,
					_input_interact,
					_input_attack,
					_input_inventory_up,
					_input_inventory_left,
					_input_inventory_down,
					_input_inventory_right,
					_input_aim,
					_input_aim_up_down,
					_input_aim_left_right
				)
			}
			
			++tick_count
			
			break
		}
	}
}