function OUIInput(_name, _default = "", _current = _default, _changed = undefined, _disabled = false) : OUIElement(_name, undefined, _disabled) constructor {
	default_value = _default
	current_value = _current
	changed = _changed
	
	static confirm = function (_value) {
		var _result = is_method(changed) ? changed(_value) : undefined
		
		if _result != undefined {
			current_value = _result
			
			return true
		}
		
		return false
	}
}