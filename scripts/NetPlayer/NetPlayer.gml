function NetPlayer() constructor {
	session = undefined
	slot = 0
	local = false
	
	ip = "127.0.0.1"
	port = 0
	key = "127.0.0.1:0"
	
	ping = 0
	ready = true
	
	name = ""
	player = undefined
	input_queue = ds_queue_create()
	
	reliable_index = 0
	reliable_received = 0
	reliable = ds_list_create()
	
	static reliable_callback = function () {
		if ds_list_empty(reliable) {
			time_source_stop(reliable_time_source)
			
			exit
		}
		
		session.send(slot, reliable[| 0], undefined, false, false)
	}
	
	reliable_time_source = time_source_create(time_source_global, 0.25, time_source_units_seconds, method(self, reliable_callback), [], -1)
	
	static destroy = function () {
		if session != undefined {
			var _players = session.players
			
			_players[| slot] = undefined
			
			var i = ds_list_size(_players)
			
			repeat i {
				--i
				
				if _players[| i] != undefined {
					break
				}
				
				ds_list_delete(_players, i)
			}
			
			--session.player_count
			
			if session.master {
				ds_map_delete(session.clients, key)
			}
		}
		
		if player != undefined {
			with player {
				net = undefined
				
				if slot != 0 {
					deactivate()
				}
			}
		}
		
		time_source_stop(reliable_time_source)
		time_source_destroy(reliable_time_source)
		
		repeat ds_list_size(reliable) {
			buffer_delete(reliable[| 0])
			ds_list_delete(reliable, 0)
		}
		
		ds_list_destroy(reliable)
		ds_queue_destroy(input_queue)
	}
}