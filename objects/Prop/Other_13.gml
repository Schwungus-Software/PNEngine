/// @description Tick
event_inherited()

var _yaw_speed = yaw_speed
var _pitch_speed = pitch_speed
var _roll_speed = roll_speed

with model {
	yaw += _yaw_speed
	pitch += _pitch_speed
	roll += _roll_speed
}