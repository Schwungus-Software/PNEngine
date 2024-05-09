/// @description Create
if is_struct(special) {
	yaw = special[$ "yaw"] ?? angle
	pitch = special[$ "pitch"] ?? pitch
	roll = special[$ "roll"] ?? 0
	fov = special[$ "fov"] ?? 45
	f_ortho = special[$ "ortho"] ?? false
	//f_sync = special[$ "sync"] ?? f_sync

	if special[$ "active"] {
		global.camera_active = id
	}
} else {
	yaw = angle
}

event_inherited()

update_matrices()

listener_pos.x = x
listener_pos.y = y
listener_pos.z = z