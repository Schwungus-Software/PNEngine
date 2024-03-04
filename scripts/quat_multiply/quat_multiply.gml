function quaternion_multiply(_q1, _q2, _q = quat_build()) {
	var _x1 = _q1[0]
	var _y1 = _q1[1]
	var _z1 = _q1[2]
	var _w1 = _q1[3]
	var _x2 = _q2[0]
	var _y2 = _q2[1]
	var _z2 = _q2[2]
	var _w2 = _q2[3]

	_q[0] = _x1 * _x2 - _y1 * _y2 - _z1 * _z2 - _w1 * _w2
	_q[1] = _x1 * _y2 + _y1 * _x2 + _z1 * _w2 - _w1 * _z2
	_q[2] = _x1 * _z2 + _z1 * _x2 + _w1 * _y2 - _y1 * _w2
	_q[3] = _x1 * _w2 + _w1 * _x2 + _y1 * _z2 - _z1 * _y2
	
	return _q
}