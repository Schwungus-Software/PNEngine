/// @desc Applies the user config's values to the game.
function config_update() {
	global.freeze_step = true
	
	with global.config {
		display_set(vid_fullscreen, vid_width, vid_height)
		display_reset(vid_antialias, vid_vsync)
		game_set_speed(vid_max_fps, gamespeed_fps)
		master_set_volume(snd_volume)
		sound_set_volume(snd_sound_volume)
		music_set_volume(snd_music_volume)
		lexicon_language_set(language)
	}
}