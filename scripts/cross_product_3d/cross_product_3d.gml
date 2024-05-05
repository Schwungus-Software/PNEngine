function cross_product_3d(_x1, _y1, _z1, _x2, _y2, _z2) {
	gml_pragma("forceinline")
	
	static result = array_create(3)
	
	result[0] = (_y1 * _z2) - (_z1 * _y2)
	result[1] = (_z1 * _x2) - (_x1 * _z2)
	result[2] = (_x1 * _y2) - (_y1 * _x2)
	
	return result
}