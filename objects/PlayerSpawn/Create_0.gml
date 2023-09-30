event_inherited()

#region Variables
	global.last_player = noone
	
	f_visible = false
	f_sync = false
#endregion

#region Virtual Functions
	player_entered = function (_player) {
		if _player.status != PlayerStatus.ACTIVE {
			exit
		}
		
		var _type = global.flags[0].get("player_class")
		
		if _type == undefined {
			exit
		}
		
		global.last_player = _player.slot
		
		var _player_pawn = area.add(_type, x, y, z, angle, tag, special)
		
		if not instance_exists(_player_pawn) {
			exit
		}
		
		with _player_pawn {
			if not is_ancestor(PlayerPawn) {
				destroy(false)
				
				exit
			}
			
			player = _player
			states = _player.states
			input = _player.input
			input_previous = _player.input_previous
		}
		
		with _player {
			if instance_exists(thing) {
				thing.destroy()
			}
			
			thing = _player_pawn
			
			if instance_exists(camera) {
				camera.destroy()
			}
			
			camera = _player_pawn.camera
		}
		
		print($"PlayerSpawn: Spawned player {_player.slot}")
	}
#endregion