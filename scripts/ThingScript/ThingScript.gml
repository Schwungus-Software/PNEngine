function ThingScript() : Script() constructor {
	name = ""
	parent = undefined
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
}