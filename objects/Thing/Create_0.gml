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

enum HitscanFlags {
	IGNORE_HOLDER = 1 << 0,
	IGNORE_MASTER = 1 << 1,
}
#endregion

#region Variables
thing_script = undefined

create = undefined
on_destroy = undefined
clean_up = undefined
tick_start = undefined
tick = undefined
tick_end = undefined
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
tosser = noone

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
voice = undefined

f_created = false
f_new = false
f_persistent = false
f_disposable = false
f_unique = false
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
f_collider_active = true
f_collider_stick = true
f_holdable = false
f_holdable_in_hand = false
f_interactive = false
f_grounded = true

m_collision = MCollision.NONE
m_bump = MBump.NONE
m_shadow = MShadow.NONE
#endregion

#region Functions
get_name = function () {
	if thing_script != undefined {
		return thing_script.name
	}
	
	return object_get_name(object_index)
}

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
	gml_pragma("forceinline")
	
	instance_destroy(self, _natural)
}

play_sound = function (_sound, _loop = false, _offset = 0, _pitch = 1, _gain = 1) {
	gml_pragma("forceinline")
	
	return area.sounds.play(_sound, _loop, _offset, _pitch, _gain)
}

play_sound_at = function (_sound, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop = false, _offset = 0, _pitch = 1, _gain = 1) {
	gml_pragma("forceinline")
	
	return area.sounds.play_at(_sound, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop, _offset, _pitch, _gain)
}

play_sound_local = function (_sound, _loop = false, _offset = 0, _pitch = 1, _gain = 1) {
	var _pool = area.sounds
	
	if emitter == undefined {
		emitter = fmod_system_create_channel_group(string(id))
		emitter_pos = new FmodVector()
		emitter_pos.x = x
		emitter_pos.y = y
		emitter_pos.z = z
		emitter_vel = new FmodVector()
		fmod_channel_group_add_group(_pool.channel_group, emitter)
		fmod_channel_control_set_paused(emitter, true)
		fmod_channel_control_set_mode(emitter, FMOD_MODE.AS_3D | FMOD_MODE.AS_3D_WORLDRELATIVE | FMOD_MODE.AS_3D_LINEARROLLOFF)
		fmod_channel_control_set_3d_attributes(emitter, emitter_pos, emitter_vel)
		fmod_channel_control_set_3d_min_max_distance(emitter, emitter_falloff, emitter_falloff_max)
		
		var _result = _pool.play_on(emitter, _sound, _loop, _offset, _pitch, _gain)
		
		fmod_channel_control_set_paused(emitter, false)
		
		return _result
	}
	
	return _pool.play_on(emitter, _sound, _loop, _offset, _pitch, _gain)
}

play_sound_ui = function (_sound, _loop = false, _offset = 0, _pitch = 1, _gain = 1) {
	gml_pragma("forceinline")
	
	return global.ui_sounds.play(_sound, _loop, _offset, _pitch, _gain)
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
	gml_pragma("forceinline")
	
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
	
	return _out
}

hitscan = function (_x1, _y1, _z1, _x2, _y2, _z2, _flags = CollisionFlags.ALL, _layers = CollisionLayers.ALL, _out = undefined, _hflags = 0) {
	return raycast(_x1, _y1, _z1, _x2, _y2, _z2, _flags, _layers, _out)
}

do_sequence = function (_sequence) {
	gml_pragma("forceinline")
	
	catspeak_execute(thing_sequenced, _sequence)
}

receive_damage = function (_amount, _type = "Normal", _from = noone, _source = _from) {
	var _result = catspeak_execute(damage_received, _from, _source, _amount, _type)
	
	if instance_exists(_from) {
		with _from {
			catspeak_execute(damage_dealt, other, _source, _amount, _type, _result)
		}
	}
	
	return _result
}

bump_avoid = function (_from, _amount = 1) {
	var _px = _from.x
	var _py = _from.y
	var _pr = _from.bump_radius
	var _len = ((bump_radius + _pr) - point_distance(_px, _py, x, y)) + math_get_epsilon()
	var _dir = point_direction(_px, _py, x, y)
	
	var _lx = lengthdir_x(_len, _dir)
	var _ly = lengthdir_y(_len, _dir)
	
	if m_collision != MCollision.NONE {
		var _z = z - (height * 0.5)
		var _raycast = raycast(x, y, _z, x + _lx + lengthdir_x(radius, _dir), y + _ly + lengthdir_y(radius, _dir), _z, CollisionFlags.BODY)
		
		if _raycast[RaycastData.HIT] {
			_dir = point_direction(0, 0, _raycast[RaycastData.NX], _raycast[RaycastData.NY])
			_lx = (_raycast[RaycastData.X] - x) + lengthdir_x(radius, _dir)
			_ly = (_raycast[RaycastData.Y] - y) + lengthdir_y(radius, _dir)
		}
		
		_lx *= _amount
		_ly *= _amount
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
		_lx *= _amount
		_ly *= _amount
		x += _lx
		y += _ly
	}
	
	return abs(_lx) != 0 or abs(_ly) != 0
}

grid_iterate = function (_type, _distance, _include_self = false) {
	static results = []
	
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
	
	with _thing {
		if not catspeak_execute(holdable_held, other, _forced) and not _forced {
			return false
		}
		
		holder = other
	}
	
	if catspeak_execute(holder_held, _thing, _forced) {
		holding = _thing
		
		return true
	}
	
	_thing.holder = noone
	
	return false
}

do_unhold = function (_tossed = false, _forced = false) {
	if not instance_exists(holding) {
		return true
	}
	
	with holding {
		if not (catspeak_execute(holdable_unheld, other, _tossed, _forced) or _forced) {
			return false
		}
	}
	
	if not (catspeak_execute(holder_unheld, holding, _tossed, _forced) or _forced) {
		return false
	}
	
	with holding {
		tosser = holder
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
	
	var _exres
	
	with _thing {
		_exres = catspeak_execute(interactive_triggered, other)
	}
	
	return _exres and catspeak_execute(interactor_triggered, _thing)
}

enter_from = function (_thing) {
	x = _thing.x
	y = _thing.y
	z = _thing.z
	angle = _thing.angle
	
	if model != undefined {
		model.move(x, y, z)
		model.rotate(angle, 0, 0)
	}
	
	with _thing {
		catspeak_execute(thing_intro, other)
	}
}
#endregion

#region Virtual Functions
player_entered = function (_player) {}
player_left = function (_player) {}
thing_intro = function (_from) {}
thing_sequenced = function (_sequence) {}
damage_dealt = function (_to, _source, _amount, _type, _result) {}

damage_received = function (_from, _source, _amount, _type) {
	return DamageResults.NONE
}

bump_check = function (_from) {
	return true
}

holder_held = function (_to, _forced) {
	return true
}

holder_unheld = function (_to, _tossed, _forced) {
	return true
}

holder_attach_holdable = function (_holding) {
	_holding.x = x
	_holding.y = y
	_holding.z = z - height
}

holdable_held = function (_from, _forced) {
	return true
}

holdable_unheld = function (_from, _tossed, _forced) {
	return true
}

interactor_triggered = function (_to) {
	return true
}

interactive_triggered = function (_from) {
	return true
}

hitscan_intercept = function (_from, _x1, _y1, _z1, _x2, _y2, _z2, _flags) {
	return true
}

thing_on_prop = function (_from) {}
#endregion