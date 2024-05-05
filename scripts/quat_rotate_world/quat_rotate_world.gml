function quat_rotate_world_z(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build
	
	var _a = _angle * 0.5
	
	rot[2] = 0.5 * dsin(_angle)
	rot[3] = 0.5 * dcos(_angle)
	
	return quat_multiply(_q1, rot, _q)
}