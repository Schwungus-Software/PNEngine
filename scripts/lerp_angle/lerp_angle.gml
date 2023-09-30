function lerp_angle(_val1, _val2, _amount) {
	gml_pragma("forceinline")
	
	return _val1 + _amount * angle_difference(_val2, _val1)
}