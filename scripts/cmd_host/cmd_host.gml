function cmd_host(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if not n {
		print("Usage: host <ip> [port] [private]")
		
		return false
	}
	
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
	
	var _ip = _parse_args[0]
	var _port = n >= 2 ? real(_parse_args[1]) : 1337
	var _private = n >= 3 ? bool(_parse_args[2]) : false
	
	if not _netgame.host(_ip, _port, _private, function () {
		global.game_status = GameStatus.NETGAME
		proControl.load_state = LoadStates.NETGAME_FINISH
		
		with global.netgame {
			show_caption($"[c_lime]{lexicon_text("netgame.hosted", $"{ip}:{port}")}")
		}
		
		game_update_status()
	}, function () {
		input_join_params_set(1, INPUT_MAX_PLAYERS, "leave", undefined, false)
		
		if not global.console {
			input_source_mode_set(INPUT_SOURCE_MODE.JOIN)
		}
		
		proControl.load_state = LoadStates.NONE
		global.game_status = GameStatus.NORMAL
		
		var _netgame = global.netgame
		
		show_caption($"[c_red]{lexicon_text("netgame.lost_connection")} ({lexicon_text("netgame.code." + _netgame.code)})")
		_netgame.destroy()
		global.netgame = undefined
	}) {
		show_caption($"[c_red]{lexicon_text("netgame.no_connection")}")
		
		return false
	}
	
	input_join_params_set(1, INPUT_MAX_PLAYERS, undefined, undefined, false)
	input_source_mode_set(INPUT_SOURCE_MODE.FIXED)
	proControl.load_state = LoadStates.NETGAME_START
	show_caption(lexicon_text("netgame.hosting", $"{_ip}:{_port}"), infinity)
	
	return true
}