#region Enums
	enum MCollision {
		NONE,
		NORMAL,
		BOUNCE,
		PROJECTILE,
	}
	
	enum MBump {
		NONE,
		ALL,
		TO,
		FROM,
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
	
	cull_tick = -1
	cull_draw = -1
	
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
	
	emitter = undefined
	emitter_falloff = 0
	emitter_falloff_max = 360
	emitter_falloff_factor = 1
	
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
	f_gravity = false
	f_culled = false
	f_cull_destroy = false
	f_garbage = false
	f_frozen = false
	
	m_collision = MCollision.NONE
	m_bump = MBump.NONE
	m_shadow = MShadow.NONE
#endregion

#region Functions
	is_ancestor = function (_type) {
		if is_string(_type) {
			if thing_script != undefined {
				return thing_script.is_ancestor(_type)
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
	
	raycast = function (_x1, _y1, _z1, _x2, _y2, _z2, _layers = CollisionLayers.ALL, _out = undefined) {
		static result = raycast_data_create()
		
		_out ??= result
		
		var _collider = area.collider
		
		if _collider != undefined {
			array_copy(_out, 0, _collider.raycast(_x1, _y1, _z1, _x2, _y2, _z2, _layers), 0, RaycastData.__SIZE)
		} else {
			result[RaycastData.HIT] = false
		}
		
		return _out
	}
	
	do_sequence = function (_sequence) {
		if is_catspeak(thing_sequenced) {
			thing_sequenced.setSelf(self)
		}
		
		thing_sequenced(_sequence)
	}
#endregion

#region Virtual Functions
	player_entered = function (_player) {}
	player_left = function (_player) {}
	thing_sequenced = function (_sequence) {}
#endregion