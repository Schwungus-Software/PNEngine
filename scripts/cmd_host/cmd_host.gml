function cmd_host(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if global.game_status == GameStatus.NETGAME {
		cmd_disconnect("")
	} else {
		if global.game_status == GameStatus.DEMO {
			print("! cmd_host: Cannot host from a demo")
			
			return false
		}
		
		if (global.players_ready + global.players_active) > 1 {
			print("! cmd_host: Cannot host with more than 1 player")
			
			return false
		}
	}
	
	var _netgame = global.netgame
	
	if _netgame == undefined {
		_netgame = new Netgame()
		global.netgame = _netgame
	}
	
	var _port = n >= 1 ? real(_parse_args[0]) : 1337
	
	if not _netgame.host(_port) {
		show_caption($"[c_red]{lexicon_text("netgame.no_connection")}")
		
		return false
	}
	
	input_join_params_set(1, INPUT_MAX_PLAYERS, undefined, undefined, false)
	input_source_mode_set(INPUT_SOURCE_MODE.FIXED)
	global.game_status = GameStatus.NETGAME
	show_caption($"[c_lime]{lexicon_text("netgame.hosting", _port)}")
	
	return true
}