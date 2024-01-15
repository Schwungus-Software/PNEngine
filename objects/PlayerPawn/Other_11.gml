/// @description Create
// Feather disable GM1014
// Feather disable GM1019
// Feather disable GM2016
event_inherited()

playcam = [x, y, z]
playcam_z = z
playcam_z_to = z

camera = area.add(PlayerCamera, x, y, z, angle)

if instance_exists(camera) {
	camera.add_target(playcam, 128, 0, 0, height + 4)
	camera.pitch = -15
}

targets = ds_priority_create()

#region Net Variables
add_net_variable("player", NetVarFlags.CREATE, function (_self, _value) {
	var _player = global.players[_value]
	
	player = _player
	states = _player.states
	input = _player.input
	input_previous = _player.input_previous
	
	with _player {
		if instance_exists(thing) and thing != other {
			instance_destroy(thing, false)
		}
		
		thing = other
		
		var _newcam = other.camera
		
		if instance_exists(camera) and camera != _newcam {
			instance_destroy(camera, false)
		}
		
		camera = _newcam
	}
}, function (_self) {
	return global.last_player
})

sync_jump = add_net_variable("net_jump", NetVarFlags.DEFAULT, function (_self, _value) {
	do_jump()
}, function (_self) {
	return undefined
})

sync_maneuver = add_net_variable("net_maneuver", NetVarFlags.DEFAULT, function (_self, _value) {
	do_maneuver()
}, function (_self) {
	return undefined
})

sync_attack = add_net_variable("net_attack", NetVarFlags.DEFAULT, function (_self, _value) {
	do_attack()
}, function (_self) {
	return undefined
})
#endregion