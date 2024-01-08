event_inherited()

if player != undefined {
	if player.thing == id {
		player.thing = noone
	}
	
	if player.camera == camera {
		player.camera = noone
	}
}

if instance_exists(camera) {
	camera.destroy(false)
}

// GROSS HACK: Because ticking still persists after cleanup
if targets != undefined {
	ds_priority_destroy(targets)
	targets = undefined
}