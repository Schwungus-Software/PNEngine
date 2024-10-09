function ColWorld() constructor {
	accelerator = undefined
	
	static add = function (_object) {
		gml_pragma("forceinline")
		
		accelerator.add(_object)
	}
	
	static remove = function (_object) {
		gml_pragma("forceinline")
		
		accelerator.remove(_object)
	}
	
	static update = function (_object) {
		gml_pragma("forceinline")
		
		remove(_object)
		add(_object)
	}
	
	static check_object = function (_object) {
		gml_pragma("forceinline")
		
		return accelerator.check_object(_object)
	}
	
	static raycast = function (_x1, _y1, _z1, _x2, _y2, _z2, _flags = CollisionFlags.ALL, _layers = CollisionLayers.ALL, _out = raycast_data_create()) {
		return _out
	}
	
	static get_objects_in_frustum = function (_frustum) {
		show_error("!!! ColWorld.get_objects_in_frustum: Not implemented", true)
	}
}