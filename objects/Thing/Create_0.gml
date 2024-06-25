#region Enums
	enum MCollision {
		NONE,
		NORMAL,
		BOUNCE,
		BULLET,
	}
	
	enum MBump {
		NONE,
		ALL, // This and other Things can bump into each other
		TO, // Only this Thing can bump into others
		FROM, // Only other Things can bump into this
	}
	
	enum MShadow {
		NONE,
		NORMAL,
		BONE,
		MODEL,
	}
#endregion

#region Variables
	thing_script = undefined
	
	create = undefined
	on_destroy = undefined
	clean_up = undefined
	tick = undefined
	draw = undefined
	draw_screen = undefined
	draw_gui = undefined
	
	level = undefined
	area = undefined
	area_thing = undefined
	
	screen_camera = noone
	screen_depth = 0
	screen_width = 0
	screen_height = 0
	gui_depth = 0
	
	tag = 0
	special = undefined
	
	target = noone
	master = noone
	holding = noone
	holder = noone
	
	cull_tick = infinity
	cull_draw = infinity
	target_priority = 0
	
	z = 0
	x_start = x
	y_start = y
	z_start = 0
	x_previous = x
	y_previous = y
	z_previous = z
	angle = 0
	angle_start = 0
	angle_previous = 0
	pitch = 0
	x_speed = 0
	y_speed = 0
	z_speed = 0
	vector_speed = 0
	move_angle = 0
	last_prop = noone
	
	fric = 0
	grav = 1
	max_fall_speed = 10
	max_fly_speed = -infinity
	
	radius = 8
	bump_radius = undefined
	hold_radius = undefined
	interact_radius = undefined
	height = 16
	floor_ray = raycast_data_create()
	wall_ray = raycast_data_create()
	ceiling_ray = raycast_data_create()
	
	shadow_x = x
	shadow_y = y
	shadow_z = 0
	shadow_radius = undefined
	shadow_ray = raycast_data_create()
	shadow_matrix = matrix_build_identity()
	
	model = undefined
	collider = undefined
	
	emitter = undefined
	emitter_falloff = 0
	emitter_falloff_max = 360
	emitter_falloff_factor = 1
	emitter_pos = undefined
	emitter_vel = undefined
	global_sounds = []
	local_sounds = []
	emitter_sounds = []
	voice = undefined
	
	bullet_damage = 1
	bullet_type = "Normal"
	
	f_created = false
	f_new = false
	f_persistent = false
	f_disposable = false
	f_unique = false
	//f_sync = true
	//f_sync_pos = true
	//f_sync_vel = true
	f_visible = true
	f_lookable = false
	f_targetable = false
	f_friend = false
	f_enemy = false
	f_gravity = false
	f_culled = false
	f_cull_destroy = false
	f_garbage = false
	f_frozen = false
	f_destroyed = false
	f_bump_passive = false
	f_bump_avoid = false
	f_bump_intercept = false
	f_bump_heavy = false
	f_collider_stick = true
	f_bullet_hitscan = false
	f_holdable = false
	f_holdable_in_hand = false
	f_interactive = false
	f_grounded = true
	
	m_collision = MCollision.NONE
	m_bump = MBump.NONE
	m_shadow = MShadow.NONE
#endregion

#region Functions
	is_ancestor = function (_type) {
		if is_string(_type) {
			if thing_script != undefined and thing_script.is_ancestor(_type) {
				return true
			}
			
			_type = asset_get_index(_type)
			
			if not object_exists(_type) {
				return false
			}
		}
		
		return object_index == _type or object_is_ancestor(object_index, _type)
	}
	
	destroy = function (_natural = true) {
		instance_destroy(id, _natural)
		
		return true
	}
	
	play_sound = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		return area.sounds.play(_sound, _loop, _offset, _pitch)
	}
	
	play_sound_at = function (_sound, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop = false, _offset = 0, _pitch = 1) {
		return area.sounds.play_at(_sound, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop, _offset, _pitch)
	}
	
	play_sound_local = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		var _pool = area.sounds
		
		if emitter == undefined {
			emitter = fmod_system_create_channel_group(string(id))
			emitter_pos = { x, y, z }
			emitter_vel = new FmodVector()
			fmod_channel_group_add_group(_pool.channel_group, emitter)
			fmod_channel_control_set_mode(emitter, FMOD_MODE.AS_3D | FMOD_MODE.AS_3D_WORLDRELATIVE | FMOD_MODE.AS_3D_LINEARROLLOFF)
			fmod_channel_control_set_3d_attributes(emitter, emitter_pos, emitter_vel)
			fmod_channel_control_set_3d_min_max_distance(emitter, emitter_falloff, emitter_falloff_max)
		}
		
		return _pool.play_on(emitter, _sound, _loop, _offset, _pitch)
	}
	
	play_sound_ui = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		return global.ui_sounds.play(_sound, _loop, _offset, _pitch)
	}
	
	play_voice = function (_sound) {
		if _sound == undefined {
			exit
		}
		
		if voice != undefined and fmod_channel_control_is_playing(voice) {
			fmod_channel_control_stop(voice)
		}
		
		voice = _sound
	}
	
	jump = function (_spd) {
		z_speed = _spd
		floor_ray[RaycastData.HIT] = false
		f_grounded = false
	}
	
	set_speed = function (_spd) {
		// Source: https://github.com/YoYoGames/GameMaker-HTML5/blob/37ebef72db6b238b892bb0ccc60184d4c4ba5d12/scripts/yyInstance.js#L1402
		if vector_speed != _spd {
			vector_speed = _spd
			x_speed = lengthdir_x(_spd, move_angle)
			y_speed = lengthdir_y(_spd, move_angle)
			
			var _rx = round(x_speed)
			
			if abs(x_speed - _rx) < 0.0001 {
				x_speed = _rx
			}
			
			var _ry = round(y_speed)
			
			if abs(y_speed - _ry) < 0.0001 {
				y_speed = _ry
			}
		}
	}
	
	set_move_angle = function (_dir) {
		// Source: https://github.com/YoYoGames/GameMaker-HTML5/blob/37ebef72db6b238b892bb0ccc60184d4c4ba5d12/scripts/yyInstance.js#L218
		while _dir > 360 {
			_dir -= 360
		}
		
		while _dir < 0 {
			_dir += 360
		}
		
		move_angle = _dir
		x_speed = lengthdir_x(vector_speed, _dir)
		y_speed = lengthdir_y(vector_speed, _dir)
		
		var _rx = round(x_speed)
		
		if abs(x_speed - _rx) < 0.0001 {
			x_speed = _rx
		}
		
		var _ry = round(y_speed)
		
		if abs(y_speed - _ry) < 0.0001 {
			y_speed = _ry
		}
	}
	
	add_motion = function (_dir, _spd) {
		x_speed += lengthdir_x(_spd, _dir)
		y_speed += lengthdir_y(_spd, _dir)
		
		// Source: https://github.com/YoYoGames/GameMaker-HTML5/blob/37ebef72db6b238b892bb0ccc60184d4c4ba5d12/scripts/yyInstance.js#L1078
		if x_speed == 0 {
			move_angle = y_speed > 0 ? 270 : (y_speed < 0 ? 90 : 0)
		} else {
			var _dd = darctan2(y_speed, x_speed)
			
			move_angle = _dd <= 0 ? -_dd : 360 - _dd
		}
		
		var _rd = round(move_angle)
		
		if (abs(move_angle - _rd) < 0.0001) {
			move_angle = _rd
		}
		
		move_angle = move_angle mod 360
		vector_speed = point_distance(0, 0, x_speed, y_speed)
		
		var _rs = round(vector_speed)
		
		if (abs(vector_speed - _rs) < 0.0001) {
			vector_speed = _rs
		}
	}
	
	raycast = function (_x1, _y1, _z1, _x2, _y2, _z2, _flags = CollisionFlags.ALL, _layers = CollisionLayers.ALL, _out = undefined) {
		static result = raycast_data_create()
		
		_out ??= result
		
		var _collider, _collidables
		
		with area {
			_collider = collider
			_collidables = collidables
		}
		
		if _collider != undefined {
			array_copy(_out, 0, _collider.raycast(_x1, _y1, _z1, _x2, _y2, _z2, _flags, _layers), 0, RaycastData.__SIZE)
			_x2 = _out[RaycastData.X]
			_y2 = _out[RaycastData.Y]
			_z2 = _out[RaycastData.Z]
		} else {
			_out[RaycastData.HIT] = false
			_out[RaycastData.X] = _x2
			_out[RaycastData.Y] = _y2
			_out[RaycastData.Z] = _z2
		}
		
		var i = ds_list_size(_collidables)
		
		repeat i {
			var _thing = _collidables[| --i]
			
			if _thing == id or _thing.f_culled or not _thing.f_prop_collision {
				continue
			}
			
			var _ray = _thing.collider.raycast(_x1, _y1, _z1, _x2, _y2, _z2, _flags, _layers)
			
			if _ray[RaycastData.HIT] {
				array_copy(_out, 0, _ray, 0, RaycastData.__SIZE)
				_out[RaycastData.THING] = _thing
				_x2 = _out[RaycastData.X]
				_y2 = _out[RaycastData.Y]
				_z2 = _out[RaycastData.Z]
			}
		}
		
		return _out
	}
	
	hitscan = function (_x1, _y1, _z1, _x2, _y2, _z2, _flags = CollisionFlags.ALL, _layers = CollisionLayers.ALL, _out = undefined) {
		var _result = raycast(_x1, _y1, _z1, _x2, _y2, _z2, _flags, _layers, _out)
		
		_x2 = _result[RaycastData.X]
		_y2 = _result[RaycastData.Y]
		_z2 = _result[RaycastData.Z]
		
		var _bump_lists, _bump_x1, _bump_y1
		
		with area {
			_bump_lists = bump_lists
			_bump_x1 = bump_x
			_bump_y1 = bump_y
		}
		
		var _width = ds_grid_width(_bump_lists)
		var _height = ds_grid_height(_bump_lists)
		var _bump_x2 = _bump_x1 + (_width * COLLIDER_REGION_SIZE)
		var _bump_y2 = _bump_y1 + (_height * COLLIDER_REGION_SIZE)
		
		// Line coordinates in grid
		var _lx1 = floor((_x1 - _bump_x1) * COLLIDER_REGION_SIZE_INVERSE)
		var _ly1 = floor((_y1 - _bump_y1) * COLLIDER_REGION_SIZE_INVERSE)
		var _lx2 = floor((_x2 - _bump_x1) * COLLIDER_REGION_SIZE_INVERSE)
		var _ly2 = floor((_y2 - _bump_y1) * COLLIDER_REGION_SIZE_INVERSE)
		
		// Distance between (lx1, ly1) and (lx2, ly2)
		var _dx = abs(_lx2 - _lx1)
		var _dy = abs(_ly2 - _ly1)
		
		// Current position
		var _x = _lx1
		var _y = _ly1
		
		// Iteration
		var _hit = false
		var _self = id
		
		var _ray_yaw = point_direction(_x1, _y1, _x2, _y2)
		var _ray_pitch = point_pitch(_x1, _y1, _z1, _x2, _y2, _z2)
		var _ray_length = point_distance_3d(_x1, _y1, _z1, _x2, _y2, _z2)
		
		var _pitch_factor = dcos(_ray_pitch)
		var _nx = dcos(_ray_yaw) * _pitch_factor
		var _ny = -dsin(_ray_yaw) * _pitch_factor
		var _nz = -dsin(_ray_pitch)
		var _x_inv = 1 / _nx
		var _y_inv = 1 / _ny
		var _z_inv = 1 / _nz
		
		var _x_step = _lx2 > _lx1 ? 1 : -1
		var _y_step = _ly2 > _ly1 ? 1 : -1
		var _error = _dx - _dy
		var _max_x = _width - 1
		var _max_y = _height - 1
		
		_dx *= 2
		_dy *= 2
		
		repeat 1 + _dx + _dy {
			var _region = _bump_lists[# clamp(_x, 0, _max_x), clamp(_y, 0, _max_y)]
			var i = ds_list_size(_region)
			
			repeat i {
				// Check this region to see if we're intersecting any Things.
				var _thing = _region[| --i]
				
				if _thing == id or _thing.holding == id or not _thing.f_bump_intercept or (f_bullet_hitscan and master == _thing) {
					continue
				}
				
				var _tx1, _ty1, _tz1, _tx2, _ty2, _tz2
				
				with _thing {
					_tx1 = x - radius
					_ty1 = y - radius
					_tz1 = z
					_tx2 = x + radius
					_ty2 = y + radius
					_tz2 = z - height
				}
				
				var _t1 = (_tx1 - _x1) * _x_inv
				var _t2 = (_tx2 - _x1) * _x_inv
				var _t3 = (_ty1 - _y1) * _y_inv
				var _t4 = (_ty2 - _y1) * _y_inv
				var _t5 = (_tz1 - _z1) * _z_inv
				var _t6 = (_tz2 - _z1) * _z_inv
				
				var _tmin = max(min(_t1, _t2), min(_t3, _t4), min(_t5, _t6))
				var _tmax = min(max(_t1, _t2), max(_t3, _t4), max(_t5, _t6))
				
				if _tmax < 0 or _tmin > _tmax {
					continue
				}
				
				var t = _tmax
				
				if _tmin > 0 {
					t = _tmin
				}
				
				var _ix = _x1 + (_nx * t)
				var _iy = _y1 + (_ny * t)
				var _iz = _z1 + (_nz * t)
				var _idist = point_distance_3d(_x1, _y1, _z1, _ix, _iy, _iz)
				
				if _idist >= _ray_length {
					continue
				}
				
				if not _thing.hitscan_intercept(_thing, _self, _x1, _y1, _z1, _x2, _y2, _z2, _flags) {
					continue
				}
				
				_x2 = _ix
				_y2 = _iy
				_z2 = _iz
				_ray_length = _idist
				_result[RaycastData.X] = _x2
				_result[RaycastData.Y] = _y2
				_result[RaycastData.Z] = _z2
				_result[RaycastData.THING] = _thing
				_hit = true
			}
			
			if _hit {
				_result[RaycastData.HIT] = true
				_result[RaycastData.NX] = -_nx
				_result[RaycastData.NY] = -_ny
				_result[RaycastData.NZ] = -_nz
				_result[RaycastData.SURFACE] = 0
				_result[RaycastData.TRIANGLE] = undefined
				
				break
			}
			
			if _error > 0 {
				_x += _x_step
				_error -= _dy
			} else {
				_y += _y_step
				_error += _dx
			}
		}
		
		return _result
	}
	
	do_sequence = function (_sequence) {
		thing_sequenced(id, _sequence)
	}
	
	receive_damage = function (_amount, _type = "Normal", _from = noone, _source = _from) {
		var _to = id
		
		var _result = damage_received(_to, _from, _source, _amount, _type)
		
		if instance_exists(_from) {
			_from.damage_dealt(_from, _to, _source, _amount, _type, _result)
		}
		
		return _result
	}
	
	bump_avoid = function (_from) {
		var _px, _py, _pr
		
		with _from {
			_px = x
			_py = y
			_pr = bump_radius
		}
		
		var _len = ((bump_radius + _pr) - point_distance(_px, _py, x, y)) + 0.001
		var _dir = point_direction(_px, _py, x, y)
		
		var _lx = lengthdir_x(_len, _dir)
		var _ly = lengthdir_y(_len, _dir)
		
		if m_collision != MCollision.NONE {
			var _z = z - height * 0.5
			var _raycast = raycast(x, y, _z, x + _lx + lengthdir_x(radius, _dir), y + _ly + lengthdir_y(radius, _dir), _z, CollisionFlags.BODY)
			
			if _raycast[RaycastData.HIT] {
				_dir = darctan2(-_raycast[RaycastData.NY], _raycast[RaycastData.NX])
				_lx = (_raycast[RaycastData.X] - x) + lengthdir_x(radius, _dir)
				_ly = (_raycast[RaycastData.Y] - y) + lengthdir_y(radius, _dir)
			}
			
			x += _lx
			y += _ly
			
			// Stick to the ground so we don't slip off of slopes
			if f_grounded {
				_raycast = raycast(x, y, _z, x, y, z + point_distance(0, 0, _lx, _ly), CollisionFlags.BODY)
				
				if _raycast[RaycastData.HIT] {
					z = _raycast[RaycastData.Z]
				}
			}
		} else {
			x += _lx
			y += _ly
		}
		
		return abs(_lx) != 0 or abs(_ly) != 0
	}
	
	grid_iterate = function (_type, _distance, _include_self = false) {
		static results = []
		
		var _bump_grid, _bump_lists, _bump_x, _bump_y
		
		with area {
			_bump_grid = bump_grid
			_bump_lists = bump_lists
			_bump_x = bump_x
			_bump_y = bump_y
		}
		
		var _grid_width = ds_grid_width(_bump_grid)
		var _grid_height = ds_grid_height(_bump_grid)
		var _grid_max_x = _grid_width - 1
		var _grid_max_y = _grid_height - 1
	
		var _gx = (x - _bump_x) * COLLIDER_REGION_SIZE_INVERSE
		var _gy = (y - _bump_y) * COLLIDER_REGION_SIZE_INVERSE
		var _gr = _distance * COLLIDER_REGION_SIZE_INVERSE
	
		var _gx1 = clamp(floor(_gx - _gr), 0, _grid_max_x)
		var _gy1 = clamp(floor(_gy - _gr), 0, _grid_max_y)
		var _gx2 = clamp(ceil(_gx + _gr), 1, _grid_width)
		var _gy2 = clamp(ceil(_gy + _gr), 1, _grid_height)
		
		var _found = 0
		var i = _gx1
		
		repeat _gx2 - _gx1 {
			var j = _gy1
		
			repeat _gy2 - _gy1 {
				var _list = _bump_lists[# i, j]
				var k = 0
			
				repeat ds_list_size(_list) {
					var _thing = _list[| k]
				
					if instance_exists(_thing) and (_thing != id or _include_self) and _thing.is_ancestor(_type) {
						results[_found++] = _thing
					}
				
					++k
				}
			
				++j
			}
		
			++i
		}
		
		array_resize(results, _found)
		
		return results
	}
	
	check_sight = function (_thing, _yaw, _pitch, _fov, _raycast = false) {
		var _tx, _ty, _tz
		
		with _thing {
			_tx = x
			_ty = y
			_tz = z - (height * 0.5)
		}
		
		if abs(angle_difference(point_direction(x, y, _tx, _ty), _yaw)) < _fov {
			var _z = z - (height * 0.5)
			
			if abs(angle_difference(_pitch, point_pitch(x, y, _z, _tx, _ty, _tz))) < _fov {
				if _raycast {
					var _ray = raycast(x, y, _z, _tx, _ty, _tz, CollisionFlags.VISION)
					
					if _ray[RaycastData.HIT] and _ray[RaycastData.THING] != _thing {
						return false
					}
				}
				
				return true
			}
		}
		
		return false
	}
	
	do_hold = function (_thing, _forced = false) {
		if not instance_exists(_thing) {
			return false
		}
		
		if not do_unhold(false, _forced) and not _forced {
			return false
		}
		
		var _holder = _thing.holder
		
		if instance_exists(_holder) and (not _holder.do_unhold(false, _forced) and not _forced) {
			return false
		}
		
		var _me = id
		
		with _thing {
			if not holdable_held(_thing, _me, _forced) and not _forced {
				return false
			}
			
			holder = _me
		}
		
		if holder_held(_me, _thing, _forced) {
			holding = _thing
			
			return true
		}
		
		return false
	}
	
	do_unhold = function (_tossed = false, _forced = false) {
		if not instance_exists(holding) {
			return true
		}
		
		if (not holding.holdable_unheld(holding, id, _tossed, _forced) or not holder_unheld(id, holding, _tossed, _forced)) and not _forced {
			return false
		}
		
		with holding {
			holder = noone
			pitch = 0
		}
		
		holding = noone
		
		return true
	}
	
	do_interact = function (_thing) {
		if not instance_exists(_thing) {
			return false
		}
		
		return _thing.interactive_triggered(_thing, id) and interactor_triggered(id, _thing)
	}
#endregion

#region Virtual Functions
	player_entered = function (_self, _player) {}
	player_left = function (_self, _player) {}
	thing_intro = function (_self, _from) {}
	thing_sequenced = function (_self, _sequence) {}
	damage_dealt = function (_self, _to, _source, _amount, _type, _result) {}
	
	damage_received = function (_self, _from, _source, _amount, _type) {
		return DamageResults.NONE
	}
	
	bump_check = function (_self, _from) {
		return true
	}
	
	holder_held = function (_self, _to, _forced) {
		return true
	}
	
	holder_unheld = function (_self, _to, _tossed, _forced) {
		return true
	}
	
	holder_attach_holdable = function (_self, _holding) {
		with _self {
			_holding.x = x
			_holding.y = y
			_holding.z = z - height
		}
	}
	
	holdable_held = function (_self, _from, _forced) {
		return true
	}
	
	holdable_unheld = function (_self, _from, _tossed, _forced) {
		return true
	}
	
	interactor_triggered = function (_self, _to) {
		return true
	}
	
	interactive_triggered = function (_self, _from) {
		return true
	}
	
	hitscan_intercept = function (_self, _from, _x1, _y1, _z1, _x2, _y2, _z2, _flags) {
		return true
	}
#endregion