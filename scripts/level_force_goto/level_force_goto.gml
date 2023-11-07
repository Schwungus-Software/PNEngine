function level_force_goto(_level, _area, _tag, _netgame) {
	gml_pragma("forceinline")
	
	with proControl {
		load_level = _level
		load_area = _area
		load_tag = _tag
		load_state = _netgame and _level != undefined ? LoadStates.NETGAME_LEVEL : LoadStates.START
	}
}