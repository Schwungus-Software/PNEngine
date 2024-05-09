function quat_build_euler(_x, _y, _z, _q = quat_build()) {
	_x = -_x * 0.5
	_y = -_y * 0.5
	_z = -_z * 0.5

	var _q1_sin, _q1_cos, _temp
	var _qx, _qy, _qz, _qw

	_q1_sin = dsin(_z)
	_q1_cos = dcos(_z)

	_temp = dsin(_x)

	_qx = _q1_cos * _temp
	_qy = _q1_sin * _temp

	_temp = dcos(_x)

	_qz = _q1_sin * _temp
	_qw = _q1_cos * _temp

	_q1_sin = dsin(_y)
	_q1_cos = dcos(_y)

	_q[0] = _qx * _q1_cos - _qz * _q1_sin
	_q[1] = _qw * _q1_sin + _qy * _q1_cos
	_q[2] = _qz * _q1_cos + _qx * _q1_sin
	_q[3] = _qw * _q1_cos - _qy * _q1_sin
	
	return _q
}