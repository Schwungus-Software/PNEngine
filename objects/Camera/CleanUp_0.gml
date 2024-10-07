event_inherited()

if global.camera_active == self {
	global.camera_active = noone
}

if instance_exists(child) {
	child.parent = noone
}

if instance_exists(parent) {
	parent.child = noone
}

ds_map_destroy(targets)
ds_map_destroy(pois)
ds_grid_destroy(path)
output.Free()