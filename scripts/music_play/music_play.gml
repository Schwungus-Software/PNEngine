function music_play(_music, _priority, _loop = true, _gain = 1, _offset = 0, _active = true) {
	gml_pragma("forceinline")
	
	if not is_instanceof(_music, Music) {
		return undefined
	}
	
	return new MusicInstance(_music, _priority, _loop, _gain, _offset, _active)
}