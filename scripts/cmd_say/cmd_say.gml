function cmd_say(_args) {
	if global.game_status == GameStatus.NETGAME {
		var b = net_buffer_create(true, NetHeaders.CHAT)
		
		buffer_write(b, buffer_string, _args)
		global.netgame.send(SEND_OTHERS, b)
	}
	
	show_caption(_args, 8 * TICKRATE)
}