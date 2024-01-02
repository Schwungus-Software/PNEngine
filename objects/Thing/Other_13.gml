/// @description Tick
x_previous = x
y_previous = y
z_previous = z

// Source: https://github.com/YoYoGames/GameMaker-HTML5/blob/37ebef72db6b238b892bb0ccc60184d4c4ba5d12/scripts/yyInstance.js#L1157
if fric != 0 {
	var _ns = vector_speed > 0 ? vector_speed - fric : vector_speed + fric
	
	if (vector_speed > 0 and _ns < 0) or (vector_speed < 0 and _ns > 0) {
		set_speed(0)
	} else {
		if vector_speed != 0 {
			set_speed(_ns)
		}
	}
}

if f_gravity and not floor_ray[RaycastData.HIT] {
	z_speed = clamp(z_speed - (area.gravity * grav), max_fall_speed, max_fly_speed)
}

// Thing collision
if m_bump != MBump.NONE and m_bump != MBump.FROM {
	var _bump_grid = area.bump_grid
	var _gx = clamp(floor((x - area.bump_x) * COLLIDER_REGION_SIZE_INVERSE), 0, ds_grid_width(_bump_grid) - 1)
	var _gy = clamp(floor((y - area.bump_y) * COLLIDER_REGION_SIZE_INVERSE), 0, ds_grid_height(_bump_grid) - 1)
	var _list = area.bump_lists[# _gx, _gy] 
	var i = 0
	
	repeat ds_list_size(_list) {
		var _thing = _list[| i++]
		
		if instance_exists(_thing) and _thing != id and _thing.m_bump != MBump.TO {
			var _tx, _ty, _tz, _th
			
			with _thing {
				_tx = x
				_ty = y
				_tz = z
				_th = height
			}
			
			// Bounding box check
			if z < (_tz + _th) and (z + height) > _tz
			   and point_distance(x, y, _tx, _ty) < bump_radius + _thing.bump_radius {
				var _bump_result
				
				with _thing {
					if is_catspeak(bump_check) {
						bump_check.setSelf(self)
					}
					
					_bump_result = bump_check(other.id)
				}
				
				if not instance_exists(id) {
					exit
				}
				
				if not _bump_result {
					continue
				}
				
				// Avoid this Thing if all these conditions are met
				var _pusher, _pushed
				
				if _thing.f_bump_avoid
				   and point_distance(0, 0, x_speed, y_speed) > point_distance(0, 0, _thing.x_speed, _thing.y_speed) {
					_pusher = id
					_pushed = _thing
				} else {
					if not f_bump_avoid {
						// None of the Things can avoid each other
						continue
					}
					
					_pusher = _thing
					_pushed = id
				}
				
				if not _pushed.bump_avoid(_pusher) and _pushed.f_bump_avoid {
					_pusher.bump_avoid(_pushed)
				}
			}
		}
	}
}

// World collision
switch m_collision {
	default:
		x += x_speed
		y += y_speed
		z += z_speed
		floor_ray[RaycastData.HIT] = false
		wall_ray[RaycastData.HIT] = false
		ceiling_ray[RaycastData.HIT] = false
	break
	
	case MCollision.NORMAL:
		var _half_height = height * 0.5
		var _center_z = z + _half_height
		
		// X-axis
		var _add_x = x + x_speed
		
		if raycast(_add_x - radius, y, _center_z, _add_x + radius, y, _center_z, CollisionFlags.BODY, CollisionLayers.ALL, wall_ray)[RaycastData.HIT] {
			var _hit_x = wall_ray[RaycastData.X]
			
			x = _hit_x + (_hit_x < x ? radius : -radius)
			x_speed = 0
		}
		
		x += x_speed
		
		// Y-axis
		var _add_y = y + y_speed
		var _raycast = raycast(x, _add_y - radius, _center_z, x, _add_y + radius, _center_z, CollisionFlags.BODY, CollisionLayers.ALL)
		
		if _raycast[RaycastData.HIT] {
			array_copy(wall_ray, 0, _raycast, 0, RaycastData.__SIZE)
			
			var _hit_y = _raycast[RaycastData.Y]
			
			y = _hit_y + (_hit_y < y ? radius : -radius)
			y_speed = 0
		}
		
		y += y_speed
		
		// Ceiling
		if raycast(x, y, z + _half_height, x, y, z + z_speed + height, CollisionFlags.BODY, CollisionLayers.ALL, ceiling_ray)[RaycastData.HIT] {
			z = ceiling_ray[RaycastData.Z] - height
			z_speed = 0
		}
		
		// Floor
		if raycast(x, y, z + _half_height, x, y, (z + z_speed) - ((floor_ray[RaycastData.HIT] and z_speed <= 0) * point_distance(x_previous, y_previous, x, y)) - math_get_epsilon(), CollisionFlags.BODY, CollisionLayers.ALL, floor_ray)[RaycastData.HIT] {
			z = floor_ray[RaycastData.Z]
			
			/*if z_speed > 0 {
				floor_ray[RaycastData.HIT] = false
			}*/
			
			if abs(floor_ray[RaycastData.NZ]) >= 0.5 {
				z_speed = 0
				
				/*// Stick to movers
				var mover =	collision[7]
				
				if instance_exists(mover) {
					var mx, my, mz, mzp, mxs, mys, myaw, myawp
					
					with mover {
						mx = x
						my = y
						mz = z
						mzp = z_previous
						mxs = x_speed
						mys = y_speed
						myaw = yaw
						myawp = yaw_previous
					}
					
					var dir_difference = angle_difference(myaw, myawp)
					var dir = point_direction(mx, my, x, y) + dir_difference
					var len = point_distance(x, y, mx, my)
					
					x = mx + lengthdir_x(len, dir) + mxs
					y = my + lengthdir_y(len, dir) + mys
					z += mz - mzp
					yaw += dir_difference
					face_direction += dir_difference
					move_direction += dir_difference
				}*/
			} else {
				x += floor_ray[RaycastData.NX]
				y += floor_ray[RaycastData.NY]
				floor_ray[RaycastData.HIT] = false
			}
		}
		
		z += z_speed
	break
}

if tick != undefined {
	tick.setSelf(self)
	tick()
}

if model != undefined {
	with model {
		tick()
		x = other.x
		y = other.y
		z = other.z
	}
}

switch m_shadow {
	default:
	case MShadow.NONE:
		shadow_ray[RaycastData.HIT] = false
	break
	
	case MShadow.NORMAL:
	case MShadow.BONE:
		var _x, _y, _z
		
		if m_shadow == MShadow.BONE and model != undefined {
			with model {
				if torso_bone <= -1 {
					_x = x
					_y = y
					_z = z + other.height * 0.5
					
					break
				}
				
				var _bone_pos = dq_get_translation(get_bone_dq(torso_bone))
				var _bone_x = _bone_pos[0]
				var _bone_y = _bone_pos[1]
				var _yaw_y = yaw - 90
				
				_x = x + lengthdir_x(_bone_x, yaw) + lengthdir_x(_bone_y, _yaw_y)
				_y = y + lengthdir_y(_bone_x, yaw) + lengthdir_y(_bone_y, _yaw_y)
				_z = z + _bone_pos[2]
			}
		} else {
			_x = x
			_y = y
			_z = z + height * 0.5
		}
		
		if raycast(_x, _y, _z, _x, _y, _z - 65535, CollisionFlags.VISION, CollisionLayers.ALL, shadow_ray)[RaycastData.HIT] {
			shadow_x = shadow_ray[RaycastData.X]
			shadow_y = shadow_ray[RaycastData.Y]
			shadow_z = shadow_ray[RaycastData.Z]
		}
	break
}