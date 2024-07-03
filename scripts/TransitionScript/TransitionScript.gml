function TransitionScript() : Script() constructor {
	internal_parent = proTransition
	
	reload = undefined
	create = undefined
	clean_up = undefined
	tick = undefined
	draw_screen = undefined
	
	static flush = function () {
		flush_function(main)
		flush_function(load)
		flush_function(reload)
		flush_function(create)
		flush_function(clean_up)
		flush_function(tick)
		flush_function(draw_screen)
	}
}