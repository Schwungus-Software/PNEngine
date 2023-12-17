#macro SOUND_POOL_SLOTS 4

function SoundPool() constructor {
	sounds = ds_list_create()
	
	gain = array_create(SOUND_POOL_SLOTS, 1)
	
	gain_start = array_create(SOUND_POOL_SLOTS, 1)
	gain_end = array_create(SOUND_POOL_SLOTS, 1)
	
	gain_time = array_create(SOUND_POOL_SLOTS, 0)
	gain_duration = array_create(SOUND_POOL_SLOTS, 0)
	
	ds_list_add(global.sound_pools, self)
	
	static play = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		if _sound == undefined {
			return undefined
		}
		
		if is_array(_sound) {
			return play(_sound[irandom(array_length(_sound) - 1)], _loop, _offset, _pitch)
		}
		
		var _id, _final_pitch
		
		with _sound {
			_id = asset
			_final_pitch = pitch_low == pitch_high ? pitch_low : random_range(pitch_low, pitch_high)
		}
		
		var _instance = audio_play_sound(_id, 0, _loop, gain[0] * gain[1] * gain[2] * gain[3] * global.sound_volume, _offset, _final_pitch)
		
		ds_list_add(sounds, _instance)
		
		return _instance
	}
	
	static play_at = function (_sound, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop = false, _offset = 0, _pitch = 1) {
		if _sound == undefined {
			return undefined
		}
		
		if is_array(_sound) {
			return play_at(_sound[irandom(array_length(_sound) - 1)],  _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop, _offset, _pitch)
		}
		
		var _id, _final_pitch
		
		with _sound {
			_id = asset
			_final_pitch = pitch_low == pitch_high ? pitch_low : random_range(pitch_low, pitch_high)
		}
		
		var _instance = audio_play_sound_at(_id, _x, _y, _z, _falloff_ref_dist, _falloff_max_dist, _falloff_factor, _loop, 0, gain[0] * gain[1] * gain[2] * gain[3] * global.sound_volume, _offset, _final_pitch)
		
		ds_list_add(sounds, _instance)
		
		return _instance
	}
	
	static play_on = function (_emitter, _sound, _loop = false, _offset = 0, _pitch = 1) {
		if _sound == undefined {
			return undefined
		}
		
		if is_array(_sound) {
			return play_on(_emitter, _sound[irandom(array_length(_sound) - 1)], _loop, _offset, _pitch)
		}
		
		var _id, _final_pitch
		
		with _sound {
			_id = asset
			_final_pitch = pitch_low == pitch_high ? pitch_low : random_range(pitch_low, pitch_high)
		}
		
		var _instance = audio_play_sound_on(_emitter, _id, _loop, 0, gain[0] * gain[1] * gain[2] * gain[3] * global.sound_volume, _offset, _final_pitch)
		
		ds_list_add(sounds, _instance)
		
		return _instance
	}
	
	static set_gain = function (_slot, _gain, _time = 0) {
		gain_time[_slot] = 0
		gain_duration[_slot] = _time
		
		if _time <= 0 {
			gain[_slot] = _gain
			
			var i = 0
			
			repeat ds_list_size(sounds) {
				audio_sound_gain(sounds[| i++], gain[0] * gain[1] * gain[2] * gain[3] * global.sound_volume, 0)
			}
			
			exit
		}
		
		gain_start[_slot] = gain[_slot]
		gain_end[_slot] = _gain
	}
	
	static clear = function () {
		repeat ds_list_size(sounds) {
			audio_stop_sound(sounds[| 0])
			ds_list_delete(sounds, 0)
		}
	}
	
	static destroy = function () {
		clear()
		ds_list_destroy(sounds)
		
		var _sound_pools = global.sound_pools
		
		ds_list_delete(_sound_pools, ds_list_find_index(_sound_pools, self))
	}
}