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