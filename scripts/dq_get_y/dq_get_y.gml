function dq_get_y(_dq) {
	gml_pragma("forceinline")
	
	return 2 * (-_dq[7] * _dq[1] + _dq[5] * _dq[3] + _dq[4] * _dq[2] - _dq[6] * _dq[0])
}