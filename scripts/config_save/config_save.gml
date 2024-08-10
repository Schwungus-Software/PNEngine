function config_save() {
	var _buffer = buffer_create(1, buffer_grow, 1)
	
	buffer_write(_buffer, buffer_text, json_stringify(global.config, true))
	buffer_save(_buffer, CONFIG_PATH)
	buffer_resize(_buffer, 1)
	buffer_seek(_buffer, buffer_seek_start, 0)
	buffer_write(_buffer, buffer_text, input_player_export(0, true, true))
	buffer_save(_buffer, CONTROLS_PATH)
	buffer_delete(_buffer)
}