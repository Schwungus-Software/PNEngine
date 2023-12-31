/// @description Create
event_inherited()

if is_struct(special) {
	var _yaw = special[$ "yaw"] ?? angle
	var _pitch = special[$ "pitch"] ?? 0
	var _roll = special[$ "roll"] ?? 0
	var _scale = special[$ "scale"] ?? 1
	var _x_scale = special[$ "x_scale"] ?? 1
	var _y_scale = special[$ "y_scale"] ?? 1
	var _z_scale = special[$ "z_scale"] ?? 1
	
	yaw_speed = special[$ "yaw_speed"] ?? 0
	pitch_speed = special[$ "pitch_speed"] ?? 0
	roll_speed = special[$ "roll_speed"] ?? 0
	
	if model == undefined {
		var _model_name = special[$ "model"]

		if not is_string(_model_name) {
			print($"! Prop.create: Invalid model name '{_model}', expected string")
			instance_destroy(id, false)
	
			exit
		}

		var _model = global.models.get(_model_name)

		if _model == undefined {
			print($"! Prop.create: Model '{_model_name}' not found")
			instance_destroy(id, false)
	
			exit
		}
		
		model = new ModelInstance(_model, x, y, z, _yaw, _pitch, _roll, _scale, _x_scale, _y_scale, _z_scale)
	
		var _collider = model.model.collider
	
		if _collider != undefined {
			collider_yaw = _yaw
			collider_yaw_previous = _yaw
			collider = new ColliderInstance(_collider)
			collider.set_matrix(matrix_build(x, y, z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale))
			ds_list_add(area.collidables, id)
		}
	} else {
		with model {
			yaw = _yaw
			pitch = _pitch
			roll = _roll
			scale = _scale
			x_scale = _x_scale
			y_scale = _y_scale
			z_scale = _z_scale
		}
		
		if collider != undefined {
			collider_yaw = _yaw
			collider_yaw_previous = _yaw
			collider.set_matrix(matrix_build(x, y, z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale))
		}
	}
} else {
	if model == undefined {
		print("! Prop.create: Special properties invalid or not found")
		instance_destroy(id, false)
		
		exit
	}
}

add_net_variable("yaw", NetVarFlags.GENERIC, function (_value) {
	model.yaw = _value
}, function () {
	return model.yaw
})

add_net_variable("pitch", NetVarFlags.GENERIC, function (_value) {
	model.pitch = _value
}, function () {
	return model.pitch
})

add_net_variable("roll", NetVarFlags.GENERIC, function (_value) {
	model.roll = _value
}, function () {
	return model.roll
})

add_net_variable("yaw_speed", NetVarFlags.GENERIC)
add_net_variable("pitch_speed", NetVarFlags.GENERIC)
add_net_variable("roll_speed", NetVarFlags.GENERIC)

add_net_variable("scale", NetVarFlags.GENERIC, function (_value) {
	model.scale = _value
}, function () {
	return model.scale
})

add_net_variable("x_scale", NetVarFlags.GENERIC, function (_value) {
	model.x_scale = _value
}, function () {
	return model.x_scale
})

add_net_variable("y_scale", NetVarFlags.GENERIC, function (_value) {
	model.y_scale = _value
}, function () {
	return model.y_scale
})

add_net_variable("z_scale", NetVarFlags.GENERIC, function (_value) {
	model.z_scale = _value
}, function () {
	return model.z_scale
})