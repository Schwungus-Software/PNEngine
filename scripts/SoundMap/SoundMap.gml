function SoundMap() : AssetMap() constructor {
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "sounds/" + _name
		var _wav_file = mod_find_file(_path + ".*", ".json")
		
		if file_exists(_wav_file) {
			var _pitch_low = 1
			var _pitch_high = 1
			var _loop_start = undefined
			var _loop_end = undefined
			var _json = json_load(mod_find_file(_path + ".json"))
			
			if is_struct(_json) {
				var _pitch = _json[$ "pitch"]
				
				if is_array(_pitch) {
					_pitch_low = _pitch[0]
					_pitch_high = _pitch[1]
				} else {
					_pitch ??= 1
					_pitch_low = _pitch
					_pitch_high = _pitch
				}
				
				_loop_start = _json[$ "loop_start"]
				_loop_end = _json[$ "loop_end"]
			}
			
			var _sound_id = fmod_system_create_sound(_wav_file, FMOD_MODE.CREATESAMPLE)
			var _sound = new Sound()
			
			with _sound {
				name = _name
				asset = _sound_id
				pitch_low = _pitch_low
				pitch_high = _pitch_high
			}
			
			if is_real(_loop_start) or is_real(_loop_end) {
				fmod_sound_set_loop_points(_sound_id, _loop_start ?? 0, FMOD_TIMEUNIT.MS, _loop_end ?? fmod_sound_get_length(_sound_id, FMOD_TIMEUNIT.MS), FMOD_TIMEUNIT.MS)
			}
			
			ds_map_add(assets, _name, _sound)
			print($"SoundMap.load: Added '{_name}' ({_sound})")
		} else {
			print($"! SoundMap.load: '{_name}' not found")
		}
	}
}

global.sounds = new SoundMap()