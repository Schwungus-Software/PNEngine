/// @description Create
yaw = special[$ "yaw"] ?? angle
pitch = special[$ "pitch"] ?? 0
roll = special[$ "roll"] ?? 0

if special[$ "active"] {
	global.camera_active = id
}

event_inherited()

update_matrices()

add_net_variable("yaw")
add_net_variable("pitch")
add_net_variable("roll")