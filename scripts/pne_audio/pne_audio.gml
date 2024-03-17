#macro AUDIO_TICKRATE 60
#macro AUDIO_TICKRATE_SECONDS 0.0166666666666667
#macro AUDIO_TICKRATE_MILLISECONDS 16.66666666666667
#macro MAX_CHANNELS 256

enum MusicPriorities {
	DEFAULT = 0,
	POWER = 8,
	SCENE = 10,
	FANFARE = 12,
}

print("pne_audio: =====[FMOD SYSTEM TEST]=====")

var _test = fmod_debug_initialize(FMOD_DEBUG_FLAGS.LEVEL_LOG)

print($"pne_audio: fmod_debug_initialize() -> value: '{_test}', result: '{fmod_last_result()}'")
global.fmod = fmod_system_create()
print($"pne_audio: fmod_system_create() -> value: '{global.fmod}', result: '{fmod_last_result()}'")
_test = fmod_system_init(MAX_CHANNELS, FMOD_INIT.NORMAL)
print($"pne_audio: fmod_system_init() -> value: '{_test}', result: '{fmod_last_result()}'")
print("pne_audio: ============================")

global.sound_group = fmod_system_create_sound_group("sound")
global.music_group = fmod_system_create_sound_group("music")
global.master_channel_group = fmod_system_get_master_channel_group()
global.sound_channel_group = fmod_system_create_channel_group("sound")
global.music_channel_group = fmod_system_create_channel_group("music")

global.master_volume = 1
global.sound_volume = 1
global.music_volume = 0.5
global.audio_focus = true

global.last_sound_pool_id = 0
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
					fmod_channel_control_set_volume(global.master_channel_group, global.master_volume)
					global.audio_focus = true
				}
			} else {
				if global.audio_focus {
					fmod_channel_control_set_volume(global.master_channel_group, 0)
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
				var _update_gain = false
				var j = 0
				
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
					fmod_channel_control_set_volume(channel_group, gain[0] * gain[1] * gain[2] * gain[3])
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
					fmod_channel_control_set_volume(sound_instance, gain[0] * gain[1] * gain[2])
				}
				
				if (stopping and gain[2] <= 0) or not fmod_channel_control_is_playing(sound_instance) {
					destroy()
				}
			}
		}
	#endregion
}, true)