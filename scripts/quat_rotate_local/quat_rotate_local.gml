function quat_rotate_local_x(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build()
	
	rot[0] = 0.5 * dsin(_angle)
	rot[3] = 0.5 * dcos(_angle)
	
	return quat_multiply(rot, _q1, _q)
}

function quat_rotate_local_y(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build()
	
	rot[1] = 0.5 * dsin(_angle)
	rot[3] = 0.5 * dcos(_angle)
	
	return quat_multiply(rot, _q1, _q)
}

function quat_rotate_local_z(_q1, _angle, _q = quat_build()) {
	gml_pragma("forceinline")
	
	static rot = quat_build()
	
	rot[2] = 0.5 * dsin(_angle)
	rot[3] = 0.5 * dcos(_angle)
	
	return quat_multiply(rot, _q1, _q)
}