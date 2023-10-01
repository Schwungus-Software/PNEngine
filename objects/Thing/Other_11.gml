/// @description Create
if create != undefined {
	create.setSelf(self)
	create()
}

if not f_sync {
	ds_list_destroy(net_variables)
	net_variables = undefined
} else {
	add_net_variable("x")
	add_net_variable("y")
	add_net_variable("z")
	add_net_variable("x_speed")
	add_net_variable("y_speed")
	add_net_variable("z_speed")
	add_net_variable("tag", NetVarFlags.CREATE)
}

if f_unique {
	var _type = object_index
	
	if thing_script != undefined {
		_type = thing_script.name
	}
	
	if area.count(_type) > 1 {
		destroy(false)
		
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