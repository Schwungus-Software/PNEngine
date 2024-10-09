function ColObject() constructor {
	shape = undefined
	thing = noone
	
	static check_object = function (_object) {
		if _object == self {
			return false
		}
		
		return shape.check_object(_object)
	}
	
	static raycast = function (_x1, _y1, _z1, _x2, _y2, _z2, _flags = CollisionFlags.ALL, _layers = CollisionLayers.ALL, _out = raycast_data_create()) {
		return _out
	}
	
	static get_min = function () {
		gml_pragma("forceinline")
		
		return shape.point_min
	}
	
	static get_max = function () {
		gml_pragma("forceinline")
		
		return shape.point_max
	}
}