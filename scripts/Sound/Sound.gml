function Sound() : Asset() constructor {
	buffer = undefined
	asset = undefined
	
	pitch_high = 1
	pitch_low = 1
	
	static destroy = function () {
		//audio_free_buffer_sound(asset)
		buffer_delete(buffer)
	}
}