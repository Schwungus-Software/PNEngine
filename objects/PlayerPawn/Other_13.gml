/// @description Tick
if player == undefined {
	exit
}

event_inherited()

/* =======
   PHYSICS
   ======= */

var _frozen = states[? "frozen"]
var _can_move = true
var _on_ground = floor_ray[RaycastData.HIT]

if _frozen /* lock_animation or player_lock or item_animation > 0 */ {
	_can_move = false
} else {
	if _on_ground and model != undefined {
		model.yaw = lerp_angle(model.yaw, instance_exists(target) ? point_direction(x, y, target.x, target.y) : move_angle, 0.4)
	}
}

var _acc

if _on_ground {
	_acc = vector_speed <= 2 ? 0.8 : 0.6 // 1.5 ? 0.324 : 0.24
	fric = 0.32 //slide_animation ? 0.18 : 0.32 // 0.12
} else {
	_acc = 0.4 // 0.1
	fric = 0.16 //slide_animation ? 0 : 0.16 // 0
}

// Looping slides are handled by player animations, this is a failsafe
//slide_animation = false

var _camera_exists = instance_exists(camera)
var _input_up_down = 0
var _input_left_right = 0

if _can_move {
	_input_up_down = input[PlayerInputs.UP_DOWN] * PLAYER_INPUT_INVERSE
	_input_left_right = input[PlayerInputs.LEFT_RIGHT] * PLAYER_INPUT_INVERSE
}

if _input_up_down != 0 or _input_left_right != 0 {
	// Match player's movement direction
	input_length = point_distance(0, 0, _input_left_right, _input_up_down)
	
	if _camera_exists {
		face_angle = camera.resolve().yaw
	}
	
	var _up = max(-_input_up_down, 0)
	var	_left = max(-_input_left_right, 0)
	var _down = max(_input_up_down, 0)
	var _right = max(_input_left_right, 0)
	
	if _up > 0 {
		add_motion(face_angle, _acc * _up)
	}
	
	if _left > 0 {
		add_motion(face_angle + 90, _acc * _left)
	}
	
	if _down > 0 {
		add_motion(face_angle + 180, _acc * _down)
	}
	
	if _right > 0 {
		add_motion(face_angle + 270, _acc * _right)
	}
	
	if vector_speed > movement_speed {
		set_speed(movement_speed)
	}
	
	face_angle += point_direction(0, 0, _input_left_right, _input_up_down) - 90
} else {
	input_length = 0
}

if _on_ground and z_speed <= 0 {
	coyote = coyote_time
	jumped = false
}

if jumped {
	var _half_jump_speed = 0.32 * jump_speed
	
	if z_speed > _half_jump_speed and (not _can_move or (input_previous[PlayerInputs.JUMP] and not input[PlayerInputs.JUMP])) {
		z_speed = _half_jump_speed
		jumped = false
	}
} else {
	if (_on_ground or coyote-- > 0)
	   and z_speed <= 0 and _can_move
	   and input[PlayerInputs.JUMP] and not input_previous[PlayerInputs.JUMP] {
		if is_catspeak(try_jump) {
			try_jump.setSelf(self)
		}
		
		if try_jump() and (sync_jump == undefined or sync_jump.update()) {
			do_jump()
		}
	}
}

interaction = PlayerInteractions.NONE

if _can_move and input[PlayerInputs.INTERACT] and not input_previous[PlayerInputs.INTERACT] {
	// Scenario 1: Attack
	if can_maneuver and input_length >= 0.1 {
		interaction = PlayerInteractions.ATTACK
	}
}

/* ======
   CAMERA
   ====== */

var _px, _py
var _has_target = instance_exists(target)

if _has_target {
	// The player is targetting a Thing, set an angle between the two
	_px = lerp(playcam[0], lerp(x, target.x, 0.5), 0.325)
	_py = lerp(playcam[1], lerp(y, target.y, 0.5), 0.325)
	playcam_z = lerp(playcam_z, lerp(z, target.z, 0.5), 0.325)
} else {
	// POSITION
	// Z-lerp if player is out of vertical range
	if _on_ground or playcam_z_snap or (playcam_z_to > z and not coyote and z_speed <= 0) or playcam_z_to + 56 < z {
		playcam_z_to = z
		
		var _playcam_z_snap_previous = playcam_z_snap
		
		playcam_z_snap = not _on_ground
		
		// Try doing a slightly smoother transition for z-lerp
		if playcam_z_snap and not _playcam_z_snap_previous {
			playcam_z_lerp = 0
		}
	} else {
		// GROSS HACK: Adjust camera Z on slopes and edges so it doesn't cause
		//             the camera to clip while unsnapped
		if shadow_ray[RaycastData.HIT] {
			playcam_z_to = max(playcam_z_to, shadow_ray[RaycastData.Z])
		}
		
		var r = -~radius
		var _rx = x + playcam_x_offset + lengthdir_x(r, move_angle)
		var _ry = y + playcam_y_offset + lengthdir_y(r, move_angle)
		var _ray = raycast(_rx, _ry, z + height * 0.5, _rx, _ry, z - 65535, CollisionFlags.CAMERA)
		
		if _ray[RaycastData.HIT] {
			playcam_z_to = max(playcam_z_to, _ray[RaycastData.Z])
		}
	}
	
	playcam_z_lerp = lerp(playcam_z_lerp, 0.25, 0.2)
	playcam_z = lerp(playcam_z, playcam_z_to, playcam_z_lerp)
	
	var _playcam_x_offset_to = lengthdir_x(12, move_angle)
	var _playcam_y_offset_to = lengthdir_y(12, move_angle)
	var _center = playcam_z + height + 4
	var _ray = raycast(x, y, _center, x + _playcam_x_offset_to, y + _playcam_y_offset_to, _center, CollisionFlags.CAMERA)
	
	if _ray[RaycastData.HIT] {
		var f = max((vector_speed / movement_speed) * 0.6, 0.125)
		
		playcam_x_offset = lerp(playcam_x_offset, _ray[RaycastData.NX], f)
		playcam_y_offset = lerp(playcam_y_offset, _ray[RaycastData.NY], f)
	} else {
		playcam_x_offset = lerp(playcam_x_offset, _playcam_x_offset_to, 0.1)
		playcam_y_offset = lerp(playcam_y_offset, _playcam_y_offset_to, 0.1)
	}
	
	_px = x + playcam_x_offset
	_py = y + playcam_y_offset
}

if _camera_exists and playcam_sync_input {
	var _input = input
	
	with camera {
		if _frozen {
			_input[PlayerInputs.FORCE_LEFT_RIGHT] = yaw
			_input[PlayerInputs.FORCE_UP_DOWN] = pitch
		} else {
			yaw = _input[PlayerInputs.AIM_LEFT_RIGHT] * PLAYER_AIM_INVERSE
			pitch = _input[PlayerInputs.AIM_UP_DOWN] * PLAYER_AIM_INVERSE
			
			if abs(pitch) > 89.5 {
				var _clamp = clamp(pitch, -89.5, 89.5)
				
				pitch = _clamp
				_input[PlayerInputs.FORCE_UP_DOWN] = _clamp
			}
		}
	}
}

// Apply to camera
playcam[0] = _px
playcam[1] = _py
playcam[2] = playcam_z