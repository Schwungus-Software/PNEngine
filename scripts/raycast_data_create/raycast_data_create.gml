function raycast_data_create() {
	gml_pragma("forceinline")
	
	var _ray = array_create(RaycastData.__SIZE, noone)
	
	_ray[RaycastData.HIT] = false
	_ray[RaycastData.X] = 0
	_ray[RaycastData.Y] = 0
	_ray[RaycastData.Z] = 0
	_ray[RaycastData.NX] = 0
	_ray[RaycastData.NY] = 0
	_ray[RaycastData.NZ] = -1
	_ray[RaycastData.SURFACE] = 0
	_ray[RaycastData.TRIANGLE] = undefined
	
	return _ray
}