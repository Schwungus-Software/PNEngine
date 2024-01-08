enum PlayerInteractions {
	NONE,
	ATTACK,
	THING,
	HOLDABLE,
	THROW,
}

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
	interaction = PlayerInteractions.NONE
	aiming = false
	aim_angle = 0
	nearest_target = noone
	untarget_buffer = false
	targets = undefined
	
	movement_speed = 6
	jump_speed = 6.44
	coyote_time = 4
	can_maneuver = true
	
	lock_animation = false
	
	playcam_x_offset = 0
	playcam_y_offset = 0
	playcam_z_lerp = 0.25
	playcam_z_snap = false
	playcam_sync_input = true
#endregion

#region Functions
	do_jump = function () {
		coyote = 0
		z_speed = jump_speed
		jumped = true
		
		if is_catspeak(player_jumped) {
			player_jumped.setSelf(self)
		}
		
		player_jumped()
	}
	
	do_maneuver = function () {}
	
	do_target = function (_thing) {
		gml_pragma("forceinline")
		
		if not aiming or target != _thing {
			aiming = true
			aim_angle = move_angle
			target = _thing
			player_aimed(_thing)
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
			player_aimed(noone)
			untarget_buffer = true
		}
	}
	
	get_state = function (_key) {
		return states[? _key]
	}
	
	set_state = function (_key, _value) {
		return player.set_state(_key, _value)
	}
#endregion

#region Virtual Functions
	try_jump = function () {
		return true
	}
	
	player_jumped = function () {}
	
	try_maneuver = function () {
		return true
	}
	
	player_maneuvered = function () {}
	player_respawned = function () {}
	player_aimed = function (_target) {}
#endregion