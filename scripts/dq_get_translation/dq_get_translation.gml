/// @desc Returns the translation of a given dual quaternion
function dq_get_translation(_dq) {
	gml_pragma("forceinline")
	
	static result = array_create(3)
	
	var _q0 = _dq[0]
	var _q1 = _dq[1]
	var _q2 = _dq[2]
	var _q3 = _dq[3]
	var _q4 = _dq[4]
	var _q5 = _dq[5]
	var _q6 = _dq[6]
	var _q7 = _dq[7]
	
	result[0] = 2 * (-_q7 * _q0 + _q4 * _q3 + _q6 * _q1 - _q5 * _q2)
	result[1] = 2 * (-_q7 * _q1 + _q5 * _q3 + _q4 * _q2 - _q6 * _q0)
	result[2] = 2 * (-_q7 * _q2 + _q6 * _q3 + _q5 * _q0 - _q4 * _q1)
	
	return result
}