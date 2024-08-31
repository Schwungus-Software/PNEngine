function player_input_to_flags(_jump, _interact, _attack, _iup, _ileft, _idown, _iright, _aim) {
	gml_pragma("forceinline")
	
	var _flags = 0
	
	if _jump { _flags |= PIFlags.JUMP }
	if _interact { _flags |= PIFlags.INTERACT }
	if _attack { _flags |= PIFlags.ATTACK }
	if _iup { _flags |= PIFlags.INVENTORY_UP }
	if _ileft { _flags |= PIFlags.INVENTORY_LEFT }
	if _idown { _flags |= PIFlags.INVENTORY_DOWN }
	if _iright { _flags |= PIFlags.INVENTORY_RIGHT }
	if _aim { _flags |= PIFlags.AIM }
	
	return _flags
}