/// @desc Resets the user config to its default values.
function config_reset() {
	global.config = {
		// DEBUG
		data_path: "data/",
		
		// USER
		language: "English",
		name: "Player",
		chat: true,
		vc_enable: false,
		vc_push: true,
		
		// VIDEO
		vid_fullscreen: false,
		vid_width: 960,
		vid_height: 540,
		vid_max_fps: 60,
		vid_vsync: false,
		vid_texture_filter: true,
		vid_antialias: 0,
		vid_bloom: true,
		
		// AUDIO
		snd_volume: 1,
		snd_sound_volume: 1,
		snd_music_volume: 0.6,
		snd_background: false,
		
		// INPUT
		in_auto_pan: true,
		in_hold_target: true,
		in_invert_x: false,
		in_invert_y: false,
		in_pan_x: 5,
		in_pan_y: 5,
		in_mouse_x: 0.025,
		in_mouse_y: 0.025,
	}
	
	input_player_reset()
}