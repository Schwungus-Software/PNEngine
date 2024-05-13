function RopeStick(_point1, _point2) constructor {
	point1 = _point1
	point2 = _point2
	length = point_distance_3d(_point1.x, _point1.y, _point1.z, _point2.x, _point2.y, _point2.z)
}

event_inherited()

points = []
sticks = []
rope_collision = false
rope_bump = false