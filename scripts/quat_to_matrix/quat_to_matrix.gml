function quat_to_matrix(_q, _matrix = matrix_build_identity()) {
	var _r = _q[0]
	var _x = _q[1]
	var _y = _q[2]
	var _z = _q[3]
	
	var _length = sqrt(sqr(_x) + sqr(_y) + sqr(_z))
	var _hyp_sqr = sqr(_length) + sqr(_r)
	
	// Calculate trig coefficients
	var _c = 2 * _r * _r / _hyp_sqr - 1
	var _s = 2 * _length * _r * _hyp_sqr
	var _omc = 1 - _c
	
	// Normalise the input vector
	var _inv = 1 / _length
	
	_x *= _inv
	_y *= _inv
	_z *= _inv
	
	// Build matrix
	_matrix[0] = _omc * _x * _x + _c
	_matrix[1] = _omc * _x * _y + _s * _z
	_matrix[2] = _omc * _x * _z - _s * _y
	_matrix[3] = 0
	_matrix[4] = _omc * _x * _y - _s * _z
	_matrix[5] = _omc * _y * _y + _c
	_matrix[6] = _omc * _y * _z + _s * _x
	_matrix[7] = 0
	_matrix[8] = _omc * _x * _z + _s * _y
	_matrix[9] = _omc * _y * _z - _s * _x
	_matrix[10] = _omc * _z * _z + _c
	_matrix[11] = 0
	_matrix[12] = 0
	_matrix[13] = 0
	_matrix[14] = 0
	_matrix[15] = 1
	
	return _matrix
}