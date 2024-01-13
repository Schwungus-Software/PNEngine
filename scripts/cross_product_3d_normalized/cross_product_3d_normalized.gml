function cross_product_3d_normalized(_x1, _y1, _z1, _x2, _y2, _z2) {
	gml_pragma("forceinline")
	
	static result = array_create(3)
	
	var _x = _y1 * _z2 - _z1 * _y2
	var _y = -(_x1 * _z2 - _z1 * _x2)
	var _z = _x1 * _y2 - _y1 * _x2
	var _inv = 1 / point_distance_3d(0, 0, 0, _x, _y, _z)
	
	result[0] = _x * _inv
	result[1] = _y * _inv
	result[2] = _z * _inv
	
	return result
}