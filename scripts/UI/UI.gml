function UI(_ui_script) constructor {
	exists = true
	ui_script = _ui_script
	
	load = undefined
	create = undefined
	clean_up = undefined
	tick = undefined
	draw_gui = undefined
	
	if _ui_script != undefined {
		load = _ui_script[$ "load"]
		create = _ui_script[$ "create"]
		clean_up = _ui_script[$ "clean_up"]
		tick = _ui_script[$ "tick"]
		draw_gui = _ui_script[$ "draw_gui"]
	}
	
	parent = undefined
	child = undefined
	
	input = global.ui_input
	
	f_blocking = true
	
	static destroy = function () {
		if not exists {
			return false
		}
		
		if parent != undefined {
			parent.child = undefined
		}
		
		if child != undefined {
			child.destroy()
			child = undefined
		}
		
		if clean_up != undefined {
			clean_up(self)
		}
		
		if global.ui == self {
			global.ui = undefined
		}
		
		exists = false
		
		return true
	}
	
	static link = function (_type) {
		gml_pragma("forceinline")
		
		if child != undefined {
			child.destroy()
		}
		
		var _ui = ui_create(_type)
		
		if _ui.exists {
			child = _ui
			_ui.parent = self
		}
	}
	
	static is_ancestor = function (_type) {
		gml_pragma("forceinline")
		
		return ui_script.is_ancestor(_type)
	}
	
	static play_sound = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		gml_pragma("forceinline")
		
		return global.ui_sounds.play(_sound, _loop, _offset, _pitch)
	}
}