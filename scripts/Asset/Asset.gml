function Asset() constructor {
	name = ""
	transient = false
	
	static destroy = function () {}
	
	static destroy_array = function (_array) {
		var i = 0
		
		repeat array_length(_array) {
			_array[i++].destroy()
		}
	}
}