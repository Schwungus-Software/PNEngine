function cmd_disconnect(_args) {
	var _netgame = global.netgame
	
	if _netgame == undefined {
		print("! cmd_disconnect: Can't disconnect if not in a netgame!")
		
		return false
	}
	
	_netgame.destroy()
	global.netgame = undefined
	global.game_status = GameStatus.DEFAULT
	input_join_params_set(1, INPUT_MAX_PLAYERS, "leave", undefined, false)
	
	if not global.console {
		input_source_mode_set(INPUT_SOURCE_MODE.JOIN)
	}
	
	global.players[0].activate()
	show_caption($"[c_red]{lexicon_text("netgame.disconnected")}")
	global.level.goto("lvlTitle")
	game_update_status()
	ds_list_clear(global.chat)
	global.chat_typing = false
	
	var _chat_line_times = global.chat_line_times
	var i = 0
	
	repeat MAX_CHAT_LINES {
		_chat_line_times[i++] = 0
	}
	
	return true
}