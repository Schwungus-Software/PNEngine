event_inherited()

if global.camera_active == id {
	global.camera_active = noone
}

if instance_exists(child) {
	child.destroy(false)
}

if instance_exists(parent) {
	parent.child = noone
}

ds_map_destroy(targets)
ds_map_destroy(pois)
output.Free()