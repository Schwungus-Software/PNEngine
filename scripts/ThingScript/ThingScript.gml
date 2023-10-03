function ThingScript() : Script() constructor {
	name = ""
	internal_parent = Thing
	
	create = undefined
	on_destroy = undefined
	clean_up = undefined
	tick = undefined
	draw = undefined
	draw_screen = undefined
	draw_gui = undefined
	
	static is_ancestor = function (_type) {
		if name == _type {
			return true
		}
		
		if parent != undefined {
			return parent.is_ancestor(_type)
		}
		
		return false
	}
	
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