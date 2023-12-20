function net_chat(_message, _color = c_white) {
	gml_pragma("forceinline")
	
	var _chat_line_times = global.chat_line_times
	var i = MAX_CHAT_LINES
	
	repeat i - 1 {
		--i
		_chat_line_times[i] = _chat_line_times[i - 1]
	}
	
	_chat_line_times[0] = CHAT_LINE_DURATION
	ds_list_add(global.chat, _message, _color)
	print($"net_chat: {_message}")
}