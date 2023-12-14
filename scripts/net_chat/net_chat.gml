function net_chat(_message, _color = "c_white") {
	gml_pragma("forceinline")
	
	ds_list_add(global.chat, $"[{_color}]{_message}")
	print($"net_chat: {_message}")
}