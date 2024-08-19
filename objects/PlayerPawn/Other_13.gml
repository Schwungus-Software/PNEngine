/// @description Tick
if player == undefined {
	exit
}

event_inherited()

if instance_exists(id) {
	catspeak_execute(player_update)
	catspeak_execute(player_update_camera)
}