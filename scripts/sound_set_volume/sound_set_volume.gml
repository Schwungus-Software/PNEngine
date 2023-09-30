function sound_set_volume(_volume) {
	global.sound_volume = _volume
	
	var _sound_pools = global.sound_pools
	var i = 0
	
	repeat ds_list_size(_sound_pools) {
		with _sound_pools[| i++] {
			var j = 0
			
			repeat ds_list_size(sounds) {
				audio_sound_gain(sounds[| j++], gain[0] * gain[1] * gain[2] * gain[3] * _volume, 0)
			}
		}
	}
}