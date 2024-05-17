/// @description Tick
if player == undefined {
	exit
}

event_inherited()

if instance_exists(id) {
	player_update(id)
	player_update_camera(id)
}