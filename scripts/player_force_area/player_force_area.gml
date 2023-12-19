function player_force_area(_scope, _id) {
	/* Move away from the current area.
	
	   If this player was the master of the area, the smallest indexed
	   player will become the next one. Otherwise the master will be
	   undefined and the area will stop ticking. */
	
	with _scope {
		var _current_area = area
		
		if _current_area != undefined {
			var _active_things = _current_area.active_things
			var i = ds_list_size(_active_things)
			
			repeat i {
				with _active_things[| --i] {
					player_left(other)
				}
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
}