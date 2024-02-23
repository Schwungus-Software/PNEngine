function music_set_volume(_volume) {
	global.music_volume = _volume
	
	/*var _music_instances = global.music_instances
	var i = 0
	
	repeat ds_list_size(_music_instances) {
		with _music_instances[| i++] {
			audio_sound_gain(sound_instance, gain[0] * gain[1] * gain[2] * _volume, 0)
		}
	}*/
}