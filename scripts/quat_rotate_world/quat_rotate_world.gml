function quat_rotate_world_z(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build()
	
	var _a = _angle * 0.5
	
	rot[0] = dcos(_a)
	rot[3] = dsin(_a)
	
	return quaternion_multiply(rot, _q1, _q)
}