function Script() : Asset() constructor {
	parent = undefined
	
	main = undefined
	load = undefined
	
	static is_ancestor = function (_type) {
		if name == _type {
			return true
		}
		
		if parent != undefined {
			return parent.is_ancestor(_type)
		}
		
		return false
	}
	
	static flush_function = function (_func) {
		if not is_catspeak(_func) {
			exit
		}
		
		with method_get_self(_func) {
			var i = 0
			
			repeat array_length(locals) {
				locals[i++] = undefined
			}
		}
		
		_func.setSelf(undefined)
	}
	
	static flush = function () {
		flush_function(main)
		flush_function(load)
	}
}