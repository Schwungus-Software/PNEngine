/// @description dq_add_translation(dq, x, y, z)
/// @param {array} dq
/// @param {real} x
/// @param {real} y
/// @param {real} z
function dq_add_translation(_dq, _x, _y, _z) {
	gml_pragma("forceinline")
	
	var q0 = _dq[0]
	var q1 = _dq[1]
	var q2 = _dq[2]
	var q3 = _dq[3]
	var q4 = _dq[4]
	var q5 = _dq[5]
	var q6 = _dq[6]
	var q7 = _dq[7]
	
	var t = [_x + 2 * (-q7 * q0 + q4 * q3 + q6 * q1 - q5 * q2), 
			 _y + 2 * (-q7 * q1 + q5 * q3 + q4 * q2 - q6 * q0), 
			 _z + 2 * (-q7 * q2 + q6 * q3 + q5 * q0 - q4 * q1)]
	
	var t0 = t[0]
	var t1 = t[1]
	var t2 = t[2]
	
	var tr = [(_x + 2 * (-q7 * q0 + q4 * q3 + q6 * q1 - q5 * q2)) * q3 + (_y + 2 * (-q7 * q1 + q5 * q3 + q4 * q2 - q6 * q0)) * q2 - (_z + 2 * (-q7 * q2 + q6 * q3 + q5 * q0 - q4 * q1)) * q1, 
			  t1 * q3 + t2 * q0 - t0 * q2, 
			  t2 * q3 + t0 * q1 - t1 * q0, 
			  - t0 * q0 - t1 * q1 - t2 * q2]
	
	tr[0] = _x * q3 + _y * q2 + _z * q1 + 2 * (
		-q7 * q0 * q3 + 
		q4 * q3 * q3 + 
		q6 * q1 * q3 - 
		q5 * q2 * q3 - 
		q7 * q1 * q2 + 
		q5 * q3 * q2 + 
		q4 * q2 * q2 - 
		q6 * q0 * q2 + 
		q7 * q2 * q1 - 
		q6 * q3 * q1 - 
		q5 * q0 * q1 + 
		q4 * q1 * q1)

	var i = 0
	
	repeat 4
	{
		_dq[i + 4] = tr[i] * 0.5;
		++i
	}
	
	return _dq
}