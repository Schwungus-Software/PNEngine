function point_pitch(_x1, _y1, _z1, _x2, _y2, _z2) {
	gml_pragma("forceinline")
	
	var _distance = max(point_distance_3d(_x1, _y1, _z1, _x2, _y2, _z2), 0.001)
	
	return darcsin(clamp((_z2 - _z1) / _distance, -1, 1))
}