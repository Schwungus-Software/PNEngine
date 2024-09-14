/// @description Tick
event_inherited()

var _yaw_speed = yaw_speed
var _pitch_speed = pitch_speed
var _roll_speed = roll_speed

model.yaw += _yaw_speed
model.pitch += _pitch_speed
model.roll += _roll_speed