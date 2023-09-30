/// @description Draw GUI
// TODO: Less crappy way to do the same effect
var i = 0

repeat timer {
	var _offset = floor(i * 0.5) * 8
	
	if i % 2 {
		draw_rectangle_color(480, 270, -_offset, 262 - _offset, c_black, c_black, c_black, c_black, false)
		draw_rectangle_color(480, 270, 472 - _offset, -_offset, c_black, c_black, c_black, c_black, false)
	} else {
		draw_rectangle_color(0, 0, 480 + _offset, 8 + _offset, c_black, c_black, c_black, c_black, false)
		draw_rectangle_color(0, 0, 8 + _offset, 270 + _offset, c_black, c_black, c_black, c_black, false)
	}
	
	++i
}