/// @description Create
move_angle = angle

if create != undefined {
	create(id)
}

if f_sync and (global.game_status & GameStatus.NETGAME) {
	if f_sync_pos {
		add_net_variable("x", NetVarFlags.GENERIC)
		add_net_variable("y", NetVarFlags.GENERIC)
		add_net_variable("z", NetVarFlags.GENERIC)
	}
	
	if f_sync_vel {
		add_net_variable("x_speed", NetVarFlags.GENERIC)
		add_net_variable("y_speed", NetVarFlags.GENERIC)
		add_net_variable("z_speed", NetVarFlags.GENERIC)
		add_net_variable("angle", NetVarFlags.CREATE)
	}
	
	add_net_variable("tag", NetVarFlags.CREATE)
} else {
	ds_list_destroy(net_variables)
	net_variables = undefined
}

if f_unique {
	var _type = object_index
	
	if thing_script != undefined {
		_type = thing_script.name
	}
	
	if area.count(_type) > 1 {
		instance_destroy(id, false)
		
		exit
	}
}

if model != undefined {
	var _collider = model.model.collider
	
	if _collider != undefined {
		var _yaw, _pitch, _roll, _scale, _x_scale, _y_scale, _z_scale
		
		with model {
			_yaw = yaw
			_pitch = pitch
			_roll = roll
			_scale = scale
			_x_scale = x_scale
			_y_scale = y_scale
			_z_scale = z_scale
		}
		
		collider_yaw = _yaw
		collider_yaw_previous = _yaw
		collider = new ColliderInstance(_collider)
		collider.set_matrix(matrix_build(x, y, z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale))
		ds_list_add(area.collidables, id)
	}
}

imgShadow = global.images.get("imgShadow")

bump_radius ??= radius
hold_radius ??= radius
interact_radius ??= radius
shadow_radius ??= radius

interp("x", "sx")
interp("y", "sy")
interp("z", "sz")
interp("shadow_x", "sshadow_x")
interp("shadow_y", "sshadow_y")
interp("shadow_z", "sshadow_z")