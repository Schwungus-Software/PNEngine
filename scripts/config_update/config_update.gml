/// @desc Applies the user config's values to the game.
function config_update() {
	global.freeze_step = true
	
	with global.config {
		display_set(vid_fullscreen, vid_width, vid_height)
	
		var _aa = vid_antialias
	
		switch _aa {
			default:
				_aa = 0
			break
		
			case 2:
				if display_aa != 2 and display_aa != 6 and display_aa != 14 {
					_aa = 0
					print("! config_update: 2x anti-aliasing not supported")
				}
			break
		
			case 4:
				if display_aa != 6 and display_aa != 12 and display_aa != 14 {
					_aa = 0
					print("! config_update: 4x anti-aliasing not supported")
				}
			break
		
			case 8:
				if display_aa != 12 and display_aa != 14 {
					_aa = 0
					print("! config_update: 8x anti-aliasing not supported")
				}
			break
		}
	
		display_reset(_aa, vid_vsync)
		game_set_speed(vid_max_fps, gamespeed_fps)
		master_set_volume(snd_volume)
		sound_set_volume(snd_sound_volume)
		music_set_volume(snd_music_volume)
		lexicon_language_set(language)
	}
}