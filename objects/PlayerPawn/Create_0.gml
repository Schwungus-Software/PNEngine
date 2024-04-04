event_inherited()

#region Variables
	player = undefined
	states = undefined
	input = undefined
	input_previous = undefined
	camera = noone
	
	input_length = 0
	jumped = false
	coyote = 0
	
	can_aim = true
	aiming = false
	aim_angle = 0
	nearest_target = noone
	nearest_holdable = noone
	nearest_interactive = noone
	untarget_buffer = false
	
	movement_speed = 6
	jump_speed = 6.44
	coyote_time = 4
	can_maneuver = true
	can_hold = true
	can_interact = true
	
	lock_animation = false
	
	playcam_x_offset = 0
	playcam_y_offset = 0
	playcam_z_lerp = 0.25
	playcam_z_snap = false
	playcam_sync_input = true
#endregion

#region Functions
	jump = function (_spd) {
		// GROSS HACK: Override the jump function so player input doesn't
		//			   affect the specified speed
		z_speed = _spd
		floor_ray[RaycastData.HIT] = false
		jumped = false
	}
	
	do_jump = function () {
		z_speed = jump_speed
		floor_ray[RaycastData.HIT] = false
		coyote = 0
		jumped = true
		player_jumped(id)
	}
	
	do_maneuver = function () {
		player_maneuvered(id)
	}
	
	do_attack = function () {
		if instance_exists(holding) and not holding.f_holdable_in_hand {
			do_unhold(true)
			
			exit
		}
		
		player_attacked(id)
	}
	
	do_target = function (_thing) {
		gml_pragma("forceinline")
		
		if not aiming or target != _thing {
			aiming = true
			aim_angle = move_angle
			target = _thing
			player_aimed(id, _thing)
		}
	}
	
	do_untarget = function () {
		gml_pragma("forceinline")
		
		if aiming {
			aiming = false
			
			if vector_speed <= 0 {
				move_angle = aim_angle
			}
			
			target = noone
			player_aimed(id, noone)
			untarget_buffer = true
		}
	}
	
	get_state = function (_key) {
		gml_pragma("forceinline")
		
		if states == undefined {
			return undefined
		}
		
		return states[? _key]
	}
	
	set_state = function (_key, _value) {
		gml_pragma("forceinline")
		
		if player == undefined {
			return false
		}
		
		return player.set_state(_key, _value)
	}
	
	respawn = function () {
		gml_pragma("forceinline")
		
		if player == undefined {
			instance_destroy()
			
			return noone
		}
		
		return player.respawn()
	}
	
	is_local = function () {
		gml_pragma("forceinline")
		
		if player == undefined {
			return false
		}
		
		return player.is_local()
	}
#endregion

#region Virtual Functions
	try_jump = function (_self) {
		return true
	}
	
	player_jumped = function (_self) {}
	
	try_maneuver = function (_self) {
		return true
	}
	
	player_maneuvered = function (_self) {}
	
	try_attack = function (_self) {
		return true
	}
	
	player_attacked = function (_self) {}
	player_aimed = function (_self, _target) {}
	player_respawned = function (_self) {}
#endregion