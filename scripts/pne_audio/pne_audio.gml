#macro AUDIO_TICKRATE 60
#macro AUDIO_TICKRATE_SECONDS 0.0166666666666667
#macro AUDIO_TICKRATE_MILLISECONDS 16.66666666666667

enum MusicPriorities {
	DEFAULT = 0,
	POWER = 8,
	SCENE = 10,
	FANFARE = 12,
}

audio_falloff_set_model(audio_falloff_linear_distance)

global.master_volume = 1
global.sound_volume = 1
global.music_volume = 0.6
global.audio_focus = true

global.sound_pools = ds_list_create()
global.ui_sounds = new SoundPool()

global.music_instances = ds_list_create()
global.music_priority = ds_priority_create()

/// @feather ignore GM2022
call_later(AUDIO_TICKRATE_SECONDS, time_source_units_seconds, function () {
	#region Play Sound When Focused
		if not global.config.snd_background {
			if window_has_focus() {
				if not global.audio_focus {
					audio_master_gain(global.master_volume)
					global.audio_focus = true
				}
			} else {
				if global.audio_focus {
					audio_master_gain(0)
					global.audio_focus = false
				}
			}
		}
	#endregion
	
	#region Update Sound Pools
		var _sound_pools = global.sound_pools
		var i = 0
		
		repeat ds_list_size(_sound_pools) {
			with _sound_pools[| i++] {
				var j = ds_list_size(sounds)
				
				repeat j {
					if not audio_exists(sounds[| --j]) {
						ds_list_delete(sounds, j)
					}
				}
				
				var _update_gain = false
				
				j = 0
				
				repeat SOUND_POOL_SLOTS {
					var _gain_time = gain_time[j]
					var _gain_duration = gain_duration[j]
					
					if _gain_time < _gain_duration {
						gain_time[j] = min(_gain_time + AUDIO_TICKRATE_MILLISECONDS, _gain_duration)
						gain[j] = lerp(gain_start[j], gain_end[j], gain_time[j] / _gain_duration)
						_update_gain = true
					}
					
					++j
				}
				
				if _update_gain {
					j = 0
					
					var _sound_volume = global.sound_volume
					
					repeat ds_list_size(sounds) {
						audio_sound_gain(sounds[| j++], gain[0] * gain[1] * gain[2] * gain[3] * _sound_volume, AUDIO_TICKRATE_MILLISECONDS)
					}
				}
			}
		}
	#endregion
	
	#region Update Music Instances
		var _music_instances = global.music_instances
		
		i = ds_list_size(_music_instances)
		
		repeat i {
			with _music_instances[| --i] {
				var _update_gain = false
				var j = 0
				
				repeat 3 {
					var _gain_time = gain_time[j]
					var _gain_duration = gain_duration[j]
					
					if _gain_time < _gain_duration {
						gain_time[j] = min(_gain_time + AUDIO_TICKRATE_MILLISECONDS, _gain_duration)
						gain[j] = lerp(gain_start[j], gain_end[j], gain_time[j] / _gain_duration)
						_update_gain = true
					}
					
					++j
				}
				
				if _update_gain {
					audio_sound_gain(sound_instance, gain[0] * gain[1] * gain[2] * global.music_volume, AUDIO_TICKRATE_MILLISECONDS)
				}
				
				if (stopping and gain[2] <= 0) or not audio_exists(sound_instance) {
					destroy()
				}
			}
		}
	#endregion
}, true)