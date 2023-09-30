function show_caption(_text, _time = -1) {
	if _time < 0 {
		_time = string_length(_text) * 4
	}
	
	with proControl {
		caption.overwrite(_text)
		caption_time = _time
	}
	
	print($"show_caption: {_text}")
}