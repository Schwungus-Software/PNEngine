function lerp_delta(val1, val2, amount) {
	gml_pragma("forceinline")
	
	return lerp(val1, val2, min(amount * global.delta, 1))
}