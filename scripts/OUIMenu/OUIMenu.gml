function OUIMenu(_name, _contents = [], _disabled = false) : OUIElement(_name, undefined, _disabled) constructor {
	option = 0
	contents = _contents
	
	var i = 0
	
	repeat array_length(_contents) {
		var _element = _contents[i++]
		
		if is_instanceof(_element, OUIElement) {
			_element.menu = other
			_element.slot = i
		}
	}
	
	i = 0
	
	repeat array_length(_contents) {
		var _element = _contents[i]
		
		if is_instanceof(_element, OUIElement) and not _element.disabled {
			option = i
			
			break
		}
		
		++i
	}
	
	from = undefined
}