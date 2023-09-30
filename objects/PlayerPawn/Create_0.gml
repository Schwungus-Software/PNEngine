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
	jump_animation = 0
	
	playcam_x_offset = 0
	playcam_y_offset = 0
	playcam_z_lerp = 0.25
	playcam_z_snap = false
	playcam_yaw_speed = 0
	playcam_yaw_speed_max = 0
#endregion

#region Functions
	do_footstep = function (_heavy = false) {
		var _sound = undefined
		
		switch floor_ray[RaycastData.SURFACE] {
			case 1:
				_sound = _heavy ? sndLand : sndFootstep
			break
			
			case 2:
				_sound = _heavy ? sndLand2 : sndFootstep2
			break
			
			case 3:
				_sound = _heavy ? sndLand3 : sndFootstep3
			break
			
			case 4:
				_sound = _heavy ? sndLand4 : sndFootstep4
			break
		}
		
		if _sound != undefined {
			play_sound_at(_sound, x, y, z, 0, _heavy ? 360 : 240, 1)
			
			return true
		}
		
		return false
	}
	
	get_state = function (_key) {
		return states[? _key]
	}
	
	set_state = function (_key, _value) {
		return player.set_state(_key, _value)
	}
#endregion

#region Virtual Functions
	player_left = function (_player) {
		if _player == player {
			destroy(false)
		}
	}
#endregion