#region Enums
	enum MCollision {
		NONE,
		NORMAL,
		BOUNCE,
		PROJECTILE,
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
	}
#endregion

#region Variables
	thing_script = undefined
	//thing_self = catspeak_special_to_struct(id)
	
	sync_id = noone
	net_variables = ds_list_create()
	
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
	x_speed = 0
	y_speed = 0
	z_speed = 0
	vector_speed = 0
	move_angle = 0
	
	fric = 0
	grav = 1
	max_fall_speed = -10
	max_fly_speed = infinity
	
	angle = 0
	
	radius = 8
	bump_radius = undefined
	height = 16
	floor_ray = raycast_data_create()
	wall_ray = raycast_data_create()
	ceiling_ray = raycast_data_create()
	
	shadow_x = x
	shadow_y = y
	shadow_z = 0
	shadow_radius = undefined
	shadow_ray = raycast_data_create()
	
	model = undefined
	collider = undefined
	collider_yaw = 0
	collider_yaw_previous = 0
	
	emitter = undefined
	emitter_falloff = 0
	emitter_falloff_max = 360
	emitter_falloff_factor = 1
	voice = undefined
	
	f_created = false
	f_new = false
	f_persistent = false
	f_disposable = false
	f_unique = false
	f_sync = true
	f_sync_pos = true
	f_sync_vel = true
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
	f_bump_avoid = false
	f_collider_stick = true
	f_holdable = false
	f_interactive = false
	
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
		if f_sync {
			var _netgame = global.netgame
			
			if _netgame != undefined {
				with _netgame {
					if not active or not master {
						return false
					}
					
					var b = net_buffer_create(true, NetHeaders.HOST_DESTROY_THING)
					
					buffer_write(b, buffer_u16, other.sync_id)
					buffer_write(b, buffer_bool, _natural)
					send(SEND_OTHERS, b)
				}
			}
		}
		
		instance_destroy(id, _natural)
		
		return true
	}
	
	add_net_variable = function (_name, _flags = NetVarFlags.DEFAULT, _read = undefined, _write = undefined) {
		if net_variables == undefined {
			return undefined
		}
		
		var i = ds_list_size(net_variables)
		
		if i >= 256 {
			show_error($"!!! Thing.add_net_variable: '{thing_script == undefined ? object_get_name(object_index) : thing_script.name}' exceeds limit of 256 NetVariables", true)
			
			return undefined
		}
		
		var _net_variable = new NetVariable(_name, _flags, _read, _write)
		
		with _net_variable {
			slot = i
			scope = other.id
			
			if _write != undefined {
				if is_catspeak(_write) {
					_write.setSelf(scope)
				}
				
				value = _write()
			}
		}
		
		ds_list_add(net_variables, _net_variable)
		
		return _net_variable
	}
	
	play_sound = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		return area.sounds.play(_sound, _loop, _offset, _pitch)
	}
	
	play_sound_at = function (_sound, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop = false, _offset = 0, _pitch = 1) {
		return area.sounds.play_at(_sound, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop, _offset, _pitch)
	}
	
	play_sound_local = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		if emitter == undefined or not audio_emitter_exists(emitter) {
			emitter = audio_emitter_create()
			audio_emitter_falloff(emitter, emitter_falloff, emitter_falloff_max, emitter_falloff_factor)
			audio_emitter_position(emitter, x, y, z)
		}
		
		return area.sounds.play_on(emitter, _sound, _loop, _offset, _pitch)
	}
	
	play_sound_ui = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		return global.ui_sounds.play(_sound, _loop, _offset, _pitch)
	}
	
	play_voice = function (_sound) {
		if _sound == undefined {
			exit
		}
		
		if voice != undefined and audio_exists(voice) {
			audio_stop_sound(voice)
		}
		
		voice = _sound
	}
	
	set_speed = function (_spd) {
		// Source: https://github.com/YoYoGames/GameMaker-HTML5/blob/37ebef72db6b238b892bb0ccc60184d4c4ba5d12/scripts/yyInstance.js#L1402
		if vector_speed != _spd {
			vector_speed = _spd
			x_speed = lengthdir_x(vector_speed, move_angle)
			y_speed = lengthdir_y(vector_speed, move_angle)
			
			var _rx = round(x_speed)
			
			if (abs(x_speed - _rx) < 0.0001) {
				x_speed = _rx
			}
			
			var _ry = round(y_speed)
			
			if (abs(y_speed - _ry) < 0.0001) {
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
		
		if (abs(x_speed - _rx) < 0.0001) {
			x_speed = _rx
		}
		
		var _ry = round(y_speed)
		
		if (abs(y_speed - _ry) < 0.0001) {
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
			
			if _thing == id or _thing.f_culled {
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
	
	do_sequence = function (_sequence) {
		if is_catspeak(thing_sequenced) {
			thing_sequenced.setSelf(self)
		}
		
		thing_sequenced(_sequence)
	}
	
	receive_damage = function (_amount, _type = "Normal", _from = noone) {
		if f_sync {
			var _netgame = global.netgame
			
			if _netgame != undefined {
				with _netgame {
					if not active or not master {
						return DamageResults.NONE
					}
					
					var b = net_buffer_create(true, NetHeaders.HOST_DAMAGE_THING)
					
					buffer_write(b, buffer_u16, other.sync_id) // Victim
					
					var _from_exists = instance_exists(_from)
					
					buffer_write(b, buffer_u16, _from_exists ? -~_from.sync_id : 0) // Attacker
					buffer_write(b, buffer_f32, _amount)
					buffer_write(b, buffer_string, _type)
					
					var _result
					
					with other {
						if is_catspeak(damage_received) {
							damage_received.setSelf(self)
						}
						
						_result = damage_received(_from, _amount, _type)
					}
					
					if _from_exists {
						var _to = other.id
						
						with _from {
							if is_catspeak(damage_dealt) {
								damage_dealt.setSelf(_from)
							}
							
							damage_dealt(_to, _amount, _type, _result)
						}
					}
					
					buffer_write(b, buffer_u8, _result)
					send(SEND_OTHERS, b)
					
					return _result
				}
			}
		}
		
		if is_catspeak(damage_received) {
			damage_received.setSelf(self)
		}
		
		var _result = damage_received(_from, _amount, _type)
		
		if instance_exists(_from) {
			with _from {
				if is_catspeak(damage_dealt) {
					damage_dealt.setSelf(self)
				}
				
				damage_dealt(other.id, _amount, _type, _result)
			}
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
			var _z = z + height * 0.5
			var _raycast = raycast(x, y, _z, x + _lx + lengthdir_x(radius, _dir), y + _ly + lengthdir_y(radius, _dir), _z)
			
			if _raycast[RaycastData.HIT] {
				_dir = darctan2(-_raycast[RaycastData.NY], _raycast[RaycastData.NX])
				_lx = (_raycast[RaycastData.X] - x) + lengthdir_x(radius, _dir)
				_ly = (_raycast[RaycastData.Y] - y) + lengthdir_y(radius, _dir)
			}
		}
		
		x += _lx
		y += _ly
		
		return point_distance(x_previous, y_previous, x, y) > 0.001
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
	
	do_hold = function (_thing, _forced = false, _sync = true) {
		if not instance_exists(_thing) {
			return false
		}
		
		if _sync and f_sync {
			var _netgame = global.netgame
			
			if _netgame != undefined {
				with _netgame {
					if not _thing.f_sync {
						break
					}
					
					if not active or not master {
						return false
					}
					
					var b = net_buffer_create(true, NetHeaders.HOST_HOLD_THING)
					
					buffer_write(b, buffer_u16, other.sync_id) // Holder
					buffer_write(b, buffer_u16, _thing.sync_id) // Holding
					buffer_write(b, buffer_bool, _forced)
					send(SEND_OTHERS, b)
				}
			}
		}
		
		if not do_unhold(_forced, false) and not _forced {
			return false
		}
		
		var _holder = _thing.holder
		
		if instance_exists(_holder) and (not _holder.do_unhold(_forced, false) and not _forced) {
			return false
		}
		
		with _thing {
			if not holdable_held(holder, _forced) and not _forced {
				return false
			}
			
			holder = other.id
		}
		
		holding = _thing
		holder_held(_thing)
		
		return true
	}
	
	do_unhold = function (_forced = false, _sync = true) {
		if not instance_exists(holding) {
			return false
		}
		
		if _sync and f_sync {
			var _netgame = global.netgame
			
			if _netgame != undefined {
				var _holding = holding
				
				with _netgame {
					if not _holding.f_sync {
						break
					}
					
					if not active or not master {
						return false
					}
					
					var b = net_buffer_create(true, NetHeaders.HOST_UNHOLD_THING)
					
					buffer_write(b, buffer_u16, other.sync_id) // Holder
					buffer_write(b, buffer_u16, _holding.sync_id) // Holding
					buffer_write(b, buffer_bool, _forced)
					send(SEND_OTHERS, b)
				}
			}
		}
		
		if (not holding.holdable_unheld(id, _forced) or not holder_unheld(holding, _forced)) and not _forced {
			return false
		}
		
		holding.holder = noone
		holding = noone
		
		return true
	}
	
	do_interact = function (_thing, _sync = true) {
		if not instance_exists(_thing) {
			return false
		}
		
		if _sync and f_sync {
			var _netgame = global.netgame
			
			if _netgame != undefined {
				var _holding = holding
				
				with _netgame {
					if not _thing.f_sync {
						break
					}
					
					if not active or not master {
						return false
					}
					
					var b = net_buffer_create(true, NetHeaders.HOST_INTERACT_THING)
					
					buffer_write(b, buffer_u16, other.sync_id) // Interactor
					buffer_write(b, buffer_u16, _thing.sync_id) // Interactive
					send(SEND_OTHERS, b)
				}
			}
		}
		
		return _thing.interactive_triggered(id) and interactor_triggered(_thing)
	}
#endregion

#region Virtual Functions
	player_entered = function (_player) {}
	player_left = function (_player) {}
	thing_sequenced = function (_sequence) {}
	damage_dealt = function (_to, _amount, _type, _result) {}
	
	damage_received = function (_from, _amount, _type) {
		return DamageResults.NONE
	}
	
	bump_check = function (_from) {
		return true
	}
	
	holder_held = function (_to, _forced) {
		return true
	}
	
	holder_unheld = function (_to, _forced) {
		return true
	}
	
	holdable_held = function (_from, _forced) {
		return true
	}
	
	holdable_unheld = function (_from, _forced) {
		return true
	}
	
	interactor_triggered = function (_to) {
		return true
	}
	
	interactive_triggered = function (_from) {
		return true
	}
#endregion