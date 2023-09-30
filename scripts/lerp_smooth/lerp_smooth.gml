function lerp_smooth(_val1, _val2, _amount) {
	gml_pragma("forceinline")
	
	return lerp(_val1, _val2, lerp(sqr(_amount), (1 - sqr(1 - _amount)), _amount))
}