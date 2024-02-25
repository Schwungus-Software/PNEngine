function Sound() : Asset() constructor {
	asset = undefined
	
	pitch_high = 1
	pitch_low = 1
	
	static destroy = function () {
		fmod_sound_release(asset)
	}
}