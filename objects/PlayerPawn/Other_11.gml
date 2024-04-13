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