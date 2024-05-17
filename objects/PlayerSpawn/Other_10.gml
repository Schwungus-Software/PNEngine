/// @description Load
var _flags = global.flags
var _type = force_type_fallback(_flags[FlagGroups.LOCAL].get("player_class"), "string", force_type(_flags[FlagGroups.GLOBAL].get("player_class"), "string"))

thing_load(_type, special)

var _players = global.players
var i = 0

repeat INPUT_MAX_PLAYERS {
	var _player = _players[i++]
	
	if _player.status == PlayerStatus.INACTIVE {
		continue
	}
	
	var _class = force_type_fallback(_player.get_state("player_class"), "string")
	
	if _class != undefined {
		thing_load(_class, special)
	}
}