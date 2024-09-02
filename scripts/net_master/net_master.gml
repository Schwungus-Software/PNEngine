function net_master() {
	gml_pragma("forceinline")
	
	var _netgame = global.netgame
	
	if _netgame == undefined {
		return true
	}
	
	with _netgame {
		if active and master {
			return true
		}
	}
	
	return false
}