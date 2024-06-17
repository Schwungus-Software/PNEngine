event_inherited()

#region Variables
	player = undefined
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
	
	movement_speed = 6
	jump_speed = -6.44
	coyote_time = 4
	can_maneuver = true
	can_hold = true
	can_interact = true
	
	lock_animation = false
	
	playcam_range = 128
	playcam_x_origin = 0
	playcam_y_origin = 0
	playcam_z_origin = -4
	playcam_x_offset = 0
	playcam_y_offset = 0
	playcam_z_lerp = 0.25
	playcam_z_snap = false
	playcam_sync_input = true
	playcam_target = undefined
#endregion

#region Functions
	jump = function (_spd) {
		// GROSS HACK: Override the jump function so player input doesn't
		//			   affect the specified speed
		z_speed = _spd
		floor_ray[RaycastData.HIT] = false
		f_grounded = false
		jumped = false
	}
	
	do_jump = function () {
		z_speed = jump_speed
		floor_ray[RaycastData.HIT] = false
		f_grounded = false
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
	
	get_state = function (_key) {
		gml_pragma("forceinline")
		
		if player == undefined {
			return undefined
		}
		
		return player.get_state(_key)
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
	
	player_create = function (_self) {}
	player_update = function (_self) {}
	player_update_camera = function (_self) {}
#endregion