/// @description Create
if is_struct(special) {
	yaw = special[$ "yaw"] ?? angle
	pitch = special[$ "pitch"] ?? 0
	roll = special[$ "roll"] ?? 0
	fov = special[$ "fov"] ?? 45

	if special[$ "active"] {
		global.camera_active = id
	}
}

event_inherited()

update_matrices()

add_net_variable("yaw", NetVarFlags.GENERIC)
add_net_variable("pitch", NetVarFlags.GENERIC)
add_net_variable("roll", NetVarFlags.GENERIC)
add_net_variable("fov", NetVarFlags.GENERIC)