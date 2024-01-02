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
	face_angle = 0
	jumped = false
	coyote = 0
	interaction = PlayerInteractions.NONE
	
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
#endregion