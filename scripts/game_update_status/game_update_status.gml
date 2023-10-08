function game_update_status() {
	/*var _status = ""
	var _total = global.players_ready + global.players_active
	var _game_status = global.game_status
	
	if _game_status == GameStatus.NETGAME {
		_status = _total > 1 ? $"Online, {_total} players" : "Online"
	} else if _game_status == GameStatus.DEMO {
		_status = "Demo"
	} else if _total > 1 {
		_status = $"{_total} players"
	}*/
	
	np_clearpresence()
	
	var _level = global.level
	
	if global.game_status == GameStatus.NETGAME {
		with global.netgame {
			if master and _level.name == "lvlTitle" {
				np_setpresence_secrets("", "", "PNEngine")
			}
			
			np_setpresence_partyparams(player_count, INPUT_MAX_PLAYERS, ip + ":" + string(port), DISCORD_PARTY_PRIVACY_PRIVATE)
		}
	}
	
	with _level {
		np_setpresence("", rp_name, rp_icon, "")
	}
}