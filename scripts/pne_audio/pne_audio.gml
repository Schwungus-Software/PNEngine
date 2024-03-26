#macro AUDIO_TICKRATE 30
#macro AUDIO_TICKRATE_SECONDS 0.0333333333333333
#macro AUDIO_TICKRATE_MILLISECONDS 33.33333333333333
#macro MAX_CHANNELS 256

enum MusicPriorities {
	DEFAULT = 0,
	POWER = 8,
	SCENE = 10,
	FANFARE = 12,
}

print("pne_audio: =====[FMOD SYSTEM TEST]=====")

var _test = fmod_debug_initialize(FMOD_DEBUG_FLAGS.LEVEL_LOG, FMOD_DEBUG_MODE.CALLBACK)
var _result = fmod_last_result()

print($"pne_audio: fmod_debug_initialize() -> value: '{_test}', result: '{_result}' ({fmod_error_string(_result)})")
global.fmod = fmod_system_create()
_result = fmod_last_result()
print($"pne_audio: fmod_system_create() -> value: '{global.fmod}', result: '{_result}' ({fmod_error_string(_result)})")
_test = fmod_system_init(MAX_CHANNELS, FMOD_INIT.NORMAL)
_result = fmod_last_result()
print($"pne_audio: fmod_system_init() -> value: '{_test}', result: '{_result}' ({fmod_error_string(_result)})")
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