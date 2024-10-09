/// @description Create
move_angle = angle

if create != undefined {
	catspeak_execute(create)
}

if f_unique {
	var _type = object_index
	
	if thing_script != undefined {
		_type = thing_script.name
	}
	
	if area.count(_type) > 1 {
		instance_destroy(self, false)
		
		exit
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