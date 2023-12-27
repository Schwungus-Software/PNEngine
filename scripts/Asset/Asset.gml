function Asset() constructor {
	name = ""
	transient = false
	
	static destroy = function () {}
	
	static destroy_array = function (_array) {
		array_foreach(_array, function (_element, _index) {
			_element.destroy()
		})
	}
}