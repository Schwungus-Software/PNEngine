if global.console {
	exit
}

var _local_slot = 0
var _netgame = global.netgame

if _netgame != undefined {
	_local_slot = _netgame.local_slot
}

var _player = global.players[_local_slot]
var _area = _player.area

_player.set_area(_area != undefined and not _area.slot)