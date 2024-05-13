event_inherited()

var i = 0

repeat array_length(points) {
	var _point = points[i++]
	
	if instance_exists(_point) {
		instance_destroy(_point, false)
	}
}