function config_save() {
	var _buffer = buffer_create(1, buffer_grow, 1)
	
	buffer_write(_buffer, buffer_text, json_stringify(global.config))
	buffer_save(_buffer, "config.json")
	buffer_resize(_buffer, 1)
	buffer_seek(_buffer, buffer_seek_start, 0)
	buffer_write(_buffer, buffer_text, input_player_export())
	buffer_save(_buffer, "controls.json")
	buffer_delete(_buffer)
}