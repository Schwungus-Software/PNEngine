function Music() : Asset() constructor {
	stream = undefined
	metadata = undefined
	cut_in = 0
	cut_out = 0
	fade_in = 0
	fade_out = 0
	
	/*static destroy = function () {
		audio_destroy_stream(stream)
	}*/
}