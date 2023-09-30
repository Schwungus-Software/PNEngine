/// @desc Applies the user config's values to the game.
function config_update() {
	var _config = global.config
	
	global.freeze_step = true
	//display_set(_config.vid_fullscreen, _config.vid_width, _config.vid_height)
	display_reset(_config.vid_antialias, _config.vid_vsync)
	game_set_speed(_config.vid_max_fps, gamespeed_fps)
	audio_master_gain(_config.snd_volume)
	sound_set_volume(_config.snd_sound_volume)
	music_set_volume(_config.snd_music_volume)
	lexicon_language_set(_config.language)
}