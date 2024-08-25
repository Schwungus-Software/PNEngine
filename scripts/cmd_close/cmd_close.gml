function cmd_close(_args) {
	input_source_mode_set(global.input_mode)
	input_verb_consume("pause")
	global.console = false
			
	if global.ui == undefined or not global.ui.f_blocking {
		fmod_channel_control_set_paused(global.world_channel_group, false)
	}
}