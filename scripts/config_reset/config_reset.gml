/// @desc Resets the user config to its default values.
function config_reset() {
	global.config = {
		// DEBUG
		data_path: "data/",
		
		// USER
		name: "Player",
		language: "English",
		
		// VIDEO
		vid_fullscreen: false,
		vid_width: 960,
		vid_height: 540,
		vid_max_fps: 60,
		vid_vsync: false,
		vid_texture_filter: true,
		vid_antialias: 0,
		vid_bloom: true,
		vid_lighting: 0,
		vid_shadow: false,
		vid_shadow_size: 256,
		
		// AUDIO
		snd_volume: 1,
		snd_sound_volume: 1,
		snd_music_volume: 0.5,
		snd_background: false,
		
		// INPUT
		in_invert_x: false,
		in_invert_y: false,
		in_pan_x: 6,
		in_pan_y: 6,
		in_mouse_x: 0.0125,
		in_mouse_y: 0.0125,
	}
	
	input_player_reset()
}