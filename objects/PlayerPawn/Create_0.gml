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
	
	playcam_range = 128
	playcam_x_origin = 0
	playcam_y_origin = 0
	playcam_z_origin = 4
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
	
	player_update = function (_self) {
		var _frozen = states[? "frozen"]
		var _can_move = true
		var _on_ground = floor_ray[RaycastData.HIT]
		
		if _frozen or lock_animation {
			_can_move = false
		} else {
			if _on_ground and model != undefined {
				var _yaw_to
		
				if aiming {
					_yaw_to = instance_exists(target) ? point_direction(x, y, target.x, target.y) : aim_angle
				} else {
					_yaw_to = move_angle
				}
		
				model.yaw = lerp_angle(model.yaw, _yaw_to, 0.4)
			}
		}
		
		var _acc
		
		if _on_ground {
			_acc = vector_speed <= 2 ? 0.8 : 0.6
			fric = 0.32
		} else {
			_acc = 0.4
			fric = 0.16
		}
		
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
				angle = camera.resolve().yaw
			}
			
			var _up = max(-_input_up_down, 0)
			var	_left = max(-_input_left_right, 0)
			var _down = max(_input_up_down, 0)
			var _right = max(_input_left_right, 0)
			
			if _up > 0 {
				add_motion(angle, _acc * _up)
			}
			
			if _left > 0 {
				add_motion(angle + 90, _acc * _left)
			}
			
			if _down > 0 {
				add_motion(angle + 180, _acc * _down)
			}
			
			if _right > 0 {
				add_motion(angle + 270, _acc * _right)
			}
			
			if vector_speed > movement_speed {
				set_speed(movement_speed)
			}
			
			angle += point_direction(0, 0, _input_left_right, _input_up_down) - 90
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
			   and input[PlayerInputs.JUMP] and not input_previous[PlayerInputs.JUMP]
			   and try_jump(id) {
				do_jump()
				_on_ground = false
			}
		}
		
		/* ===========
		   INTERACTION
		   =========== */
		
		var _has_target = instance_exists(target)
		
		if _has_target {
			var _x, _y, _z
			
			with target {
				_x = x
				_y = y
				_z = z
			}
			
			aim_angle = point_direction(x, y, _x, _y)
			pitch = point_pitch(x, y, z, _x, _y, _z)
		} else {
			if not aiming {
				aim_angle = angle
			}
			
			pitch = 0
		}
		
		if instance_exists(holding) {
			holding.angle = aim_angle
			holding.pitch = pitch
		}
		
		nearest_holdable = noone
		nearest_interactive = noone
		
		if _can_move {
			if input[PlayerInputs.ATTACK] and not input_previous[PlayerInputs.ATTACK] and try_attack(id) {
				do_attack()
			}
			
			var _moving = input_length >= 0.1
			var _can_maneuver = can_maneuver and _moving
			
			if _on_ground and not _can_maneuver {
				if can_interact {
					// Scan for nearby interactives and holdables
					var _radius = interact_radius + 10
					var _neardist = infinity
					var _things = grid_iterate(Thing, _radius)
					var i = 0
					
					repeat array_length(_things) {
						var _thing = _things[i++]
						
						if _thing.f_interactive and not instance_exists(_thing.holder) {
							var _dist = point_distance_3d(x, y, z, _thing.x, _thing.y, _thing.z)
							
							if _dist < _neardist and _dist < (_radius + _thing.interact_radius) {
								nearest_interactive = _thing
								_neardist = _dist
							}
						}
					}
				}
				
				if can_hold and not instance_exists(holding) and not instance_exists(nearest_interactive) {
					var _radius = hold_radius + 10
					var _neardist = infinity
					var _things = grid_iterate(Thing, _radius)
					var i = 0
					
					repeat array_length(_things) {
						var _thing = _things[i++]
						
						if _thing.f_holdable and not instance_exists(_thing.holder) {
							var _dist = point_distance_3d(x, y, z, _thing.x, _thing.y, _thing.z)
							
							if _dist < _neardist and _dist < (_radius + _thing.hold_radius) {
								nearest_holdable = _thing
								_neardist = _dist
							}
						}
					}
				}
			}
			
			// Input
			if input[PlayerInputs.INTERACT] and not input_previous[PlayerInputs.INTERACT] {
				if not _can_maneuver and instance_exists(nearest_interactive) {
					do_interact(nearest_interactive)
				} else {
					if instance_exists(holding) {
						if aiming or _moving or not _on_ground {
							// Scenario: Throw
							do_unhold(true)
						} else {
							// Scenario: Drop
							do_unhold()
						}
					} else {
						if _can_maneuver {
							// Scenario: Maneuver
							do_maneuver()
						} else {
							if instance_exists(nearest_holdable) {
								// Scenario: Pick Up
								do_hold(nearest_holdable)
							}
						}
					}
				}
			}
		}
		
		/* =================
		   LOCK-ON TARGETING
		   ================== */
		
		if target != noone
		   and (not can_aim
				or not instance_exists(target) 
		        or target.f_culled 
				or not target.f_targetable 
				or instance_exists(target.holder) 
				or point_distance_3d(x, y, z, target.x, target.y, target.z) > 256) {
			do_untarget()
		}
		
		nearest_target = noone
		
		if not _frozen {
			var _best = infinity
			var _things = grid_iterate(Thing, 256)
			var i = array_length(_things)
			
			repeat i {
				var _thing = _things[--i]
				
				if _thing == target or not _thing.f_targetable or instance_exists(_thing.holder) {
					continue
				}
				
				var _x, _y
				
				with _thing {
					_x = x
					_y = y
				}
				
				var _dist = point_distance_3d(x, y, z, _x, _y, _thing.z)
				
				if _dist >= 256 {
					continue
				}
				
				var _diff = abs(angle_difference(point_direction(x, y, _x, _y), move_angle))
				
				if _diff > 75 {
					continue
				}
				
				// Smallest priority value is considered the nearest target
				var _priority = _dist
				
				with _thing {
					_priority -= target_priority + f_enemy - f_friend
				}
				
				if _priority < _best {
					nearest_target = _thing
					_best = _priority
				}
			}
		}
		
		if not _frozen and can_aim and input[PlayerInputs.AIM] {
			var _can_target = instance_exists(nearest_target)
			
			if _can_target {
				if not input_previous[PlayerInputs.AIM] {
					do_target(nearest_target)
					_has_target = _can_target
				}
			} else {
				if not aiming {
					if not untarget_buffer {
						do_target(noone)
					}
				} else if _has_target and not input_previous[PlayerInputs.AIM] {
					do_untarget()
					_has_target = false
				}
			}
		} else {
			untarget_buffer = false
			
			if aiming and not _has_target {
				do_untarget()
			}
		}
	}
	
	player_update_camera = function (_self) {
		var _has_target = instance_exists(target)
		var _camera_exists = instance_exists(camera)
		var _on_ground = floor_ray[RaycastData.HIT]
		var _frozen = states[? "frozen"]
		var _px, _py
		
		if aiming {
			var _x_to, _y_to, _z_to
			
			if _has_target {
				// The player is targetting a Thing, set an angle between the two
				_x_to = lerp(x, target.x, 0.5)
				_y_to = lerp(y, target.y, 0.5)
				_z_to = lerp(z, target.z, 0.5)
			} else {
				// Not targetting anything, focus towards direction
				_x_to = x + lengthdir_x(6, aim_angle)
				_y_to = y + lengthdir_y(6, aim_angle)
				_z_to = z + 6
				
				if _camera_exists {
					with camera {
						yaw = lerp_angle(yaw, other.aim_angle, 0.325)
						pitch = lerp_angle(pitch, 0, 0.325)
					}
				}
			}
			
			_px = lerp(playcam[0], _x_to, 0.325)
			_py = lerp(playcam[1], _y_to, 0.325)
			playcam_z = lerp(playcam_z, _z_to, 0.325)
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
			var _aiming = aiming
			
			with camera {
				if _frozen or (_aiming and not _has_target) {
					_input[PlayerInputs.FORCE_LEFT_RIGHT] = yaw
					_input[PlayerInputs.FORCE_UP_DOWN] = pitch
				} else {
					f_raycast = not (_aiming and _has_target)
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
	}
#endregion