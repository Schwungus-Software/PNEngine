function Font() : Asset() constructor {
	sprite = undefined
	font = undefined
	
	static destroy = function () {
		scribble_font_delete(name)
		font_delete(font)
		
		if sprite != undefined {
			sprite_delete(sprite)
		}
	}
}