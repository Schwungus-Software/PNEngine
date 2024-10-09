function Collider() : Asset() constructor {
	triangles = ds_list_create()
	regions = ds_list_create()
	grid = ds_grid_create(1, 1)
	x1 = -infinity
	y1 = -infinity
	x2 = infinity
	y2 = infinity
	layer_mask = 0xFF
	
	static destroy = function () {
		ds_list_destroy(triangles)
		ds_list_destroy(regions)
		ds_grid_destroy(grid)
	}
}