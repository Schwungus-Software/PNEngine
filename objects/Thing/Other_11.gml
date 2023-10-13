/// @description Create
if create != undefined {
	create.setSelf(self)
	create()
}

var _game_status = global.game_status

if not (global.game_status & GameStatus.NETGAME) or not f_sync {
	ds_list_destroy(net_variables)
	net_variables = undefined
} else {
	add_net_variable("x", NetVarFlags.GENERIC)
	add_net_variable("y", NetVarFlags.GENERIC)
	add_net_variable("z", NetVarFlags.GENERIC)
	add_net_variable("x_speed", NetVarFlags.GENERIC)
	add_net_variable("y_speed", NetVarFlags.GENERIC)
	add_net_variable("z_speed", NetVarFlags.GENERIC)
	add_net_variable("tag", NetVarFlags.CREATE)
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

imgShadow = global.images.get("imgShadow")

bump_radius ??= radius
shadow_radius ??= radius

interp("x", "sx")
interp("y", "sy")
interp("z", "sz")
interp("shadow_x", "sshadow_x")
interp("shadow_y", "sshadow_y")
interp("shadow_z", "sshadow_z")