function SoundMap() : AssetMap() constructor {
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "sounds/" + _name
		var _wav_file = mod_find_file(_path + ".wav")
		
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
			
			// Load the WAV file (header offset is 42) (thanks, TabularElf)
			var _original_buffer = buffer_load(_wav_file)
			var _buffer_size = buffer_get_size(_original_buffer)
			var _buffer = buffer_create(_buffer_size, buffer_fixed, 1)
			
			buffer_copy(_original_buffer, 0, _buffer_size, _buffer, 0)
			buffer_delete(_original_buffer)
			
			// Set Seek
			buffer_seek(_buffer, buffer_seek_start, 0)
			
			// Check RIFF header
			var _chunk_id = buffer_peek(_buffer, 0, buffer_u32)
			
			if _chunk_id != 0x46464952 {
				show_error($"!!! SoundMap.load: Sound '{_name}' has invalid chunk ID", true)
			}
			
			var _signature = buffer_peek(_buffer, 8, buffer_u32)
			
			if _signature == 0x45564157 {
				// This is a WAV
				if buffer_peek(_buffer, 12, buffer_u8) == 0x66
				   and buffer_peek(_buffer, 13, buffer_u8) == 0x6D
				   and buffer_peek(_buffer, 14, buffer_u8) == 0x74
				   and buffer_peek(_buffer, 15, buffer_u8) == 0x20 {
					// This is an FMT
					var _channels = buffer_peek(_buffer, 22, buffer_u16)
					var _channel
					
					switch _channels {
						case 1:
							_channel = audio_mono
						break
						
						case 2:
							_channel = audio_stereo
						break
						
						default:
							show_error($"!!! SoundMap.load: Sound '{_name}' has invalid amount of channels", true)
					}
					
					var _rate = buffer_peek(_buffer, 24, buffer_u32)
					var _bits_per_sample = buffer_peek(_buffer, 34, buffer_u16)
					
					// We're going to skip ahead and find data, as some wav files contain a
					// LIST-INFO chunk.
					var i = 0
					
					while buffer_peek(_buffer, 36 + i, buffer_u32) != 0x61746164 {
						++i
					}
					
					var _subchunk_size = buffer_peek(_buffer, 40 + i, buffer_u32)
					
					switch _bits_per_sample {
						case 8:
							_bits_per_sample = buffer_u8
						break
						
						case 16:
							_bits_per_sample = buffer_s16
						break
						
						default:
							show_error($"!!! SoundMap.load: Sound '{_name}' has invalid bits per sample", true)
					}
					
					//var _sound_id = audio_create_buffer_sound(_buffer, _bits_per_sample, _rate, 42 + i, _subchunk_size, _channel)
					var _sound = new Sound()
					
					with _sound {
						name = _name
						buffer = _buffer
						//asset = _sound_id
						pitch_low = _pitch_low
						pitch_high = _pitch_high
					}
					
					/*if is_real(_loop_start) {
						audio_sound_loop_start(_sound_id, _loop_start)
					}
					
					if is_real(_loop_end) {
						audio_sound_loop_end(_sound_id, _loop_end)
					}*/
					
					ds_map_add(assets, _name, _sound)
					print($"SoundMap.load: Added '{_name}' ({_sound})")
				} else {
					show_error($"!!! SoundMap.load: Sound '{_name}' has incorrect FMT", true)
				}
			} else {
				show_error($"!!! SoundMap.load: Sound '{_name}' has invalid signature", true)
			}
		} else {
			print($"! SoundMap.load: '{_name}' not found")
		}
	}
}

global.sounds = new SoundMap()