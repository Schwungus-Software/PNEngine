function UIScript() : Script() constructor {
	internal_parent = UI
	
	create = undefined
	clean_up = undefined
	tick = undefined
	draw_gui = undefined
	
	static flush = function () {
		flush_function(main)
		flush_function(load)
		flush_function(create)
		flush_function(clean_up)
		flush_function(tick)
		flush_function(draw_gui)
	}
}