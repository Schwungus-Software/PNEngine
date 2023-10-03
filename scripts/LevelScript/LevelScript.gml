function LevelScript() : Script() constructor {
	parent = undefined
	
	start = undefined
	area_changed = undefined
	area_activated = undefined
	area_deactivated = undefined
	
	static flush = function () {
		flush_function(main)
		flush_function(load)
		flush_function(start)
		flush_function(area_changed)
		flush_function(area_activated)
		flush_function(area_deactivated)
	}
}