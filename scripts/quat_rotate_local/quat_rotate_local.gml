function quat_rotate_local_x(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build()
	
	var _a = _angle * 0.5
	
	rot[0] = dcos(_a)
	rot[1] = dsin(_a)
	
	return quaternion_multiply(_q1, rot, _q)
}

function quat_rotate_local_y(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build()
	
	var _a = _angle * 0.5
	
	rot[0] = dcos(_a)
	rot[3] = dsin(_a)
	
	return quaternion_multiply(_q1, rot, _q)
}

function quat_rotate_local_z(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build()
	
	var _a = _angle * 0.5
	
	rot[0] = dcos(_a)
	rot[2] = dsin(_a)
	
	return quaternion_multiply(_q1, rot, _q)
}