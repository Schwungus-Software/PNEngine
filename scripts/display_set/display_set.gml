/// @desc Safely change the game's display.
/// @param {bool} fullscreen
/// @param {real} width
/// @param {real} height
function display_set(fullscreen, width, height) {
	if fullscreen {
		window_set_fullscreen(true)
		
		while not window_get_fullscreen() {}
		
		width = display_get_width()
		height = display_get_height()
	} else {
		window_set_fullscreen(false)
		
		while window_get_fullscreen() {}
		
		var dw = display_get_width()
		var dh = display_get_height()
		
		width = min(width, dw)
		height = min(height, dh)
		
		window_set_rectangle((dw * 0.5) - (width * 0.5), (dh * 0.5) - (height * 0.5), width, height)
	}
	
	global.freeze_step = true
}