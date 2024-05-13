/// @description Draw
event_inherited()

batch_set_properties()

var i = 0

repeat array_length(sticks) {
	with sticks[i++] {
		batch_billboard(-1, 0, 0.5, 0.5, point1.sx, point1.sy, point1.sz)
		batch_billboard(-1, 0, 0.5, 0.5, point2.sx, point2.sy, point2.sz)
		batch_line(-1, 0, point1.sx, point1.sy, point1.z, point2.sx, point2.sy, point2.sz, 0.25, c_black)
	}
}