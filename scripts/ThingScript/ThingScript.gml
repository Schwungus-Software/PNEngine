function ThingScript() : Script() constructor {
	internal_parent = Thing
	
	create = undefined
	on_destroy = undefined
	clean_up = undefined
	tick = undefined
	draw = undefined
	draw_screen = undefined
	draw_gui = undefined
	
	static flush = function () {
		flush_function(main)
		flush_function(load)
		flush_function(create)
		flush_function(on_destroy)
		flush_function(clean_up)
		flush_function(tick)
		flush_function(draw)
		flush_function(draw_screen)
		flush_function(draw_gui)
	}
}