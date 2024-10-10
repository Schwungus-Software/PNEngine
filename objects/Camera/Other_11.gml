/// @description Create
if is_struct(special) {
	yaw = force_type_fallback(special[$ "yaw"], "number", angle)
	pitch = force_type_fallback(special[$ "pitch"], "number", 0)
	roll = force_type_fallback(special[$ "roll"], "number", 0)
	fov = force_type_fallback(special[$ "fov"], "number", 45)
	f_ortho = force_type_fallback(special[$ "ortho"], "bool", false)
	
	if force_type_fallback(special[$ "active"], "bool", false) {
		global.camera_active = self
	}
} else {
	yaw = angle
}

event_inherited()

update_matrices()

listener_pos.x = x
listener_pos.y = y
listener_pos.z = z