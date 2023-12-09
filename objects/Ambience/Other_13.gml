/// @description Tick
event_inherited()

var i = 0

repeat array_length(ambience) {
	var _amb = ambience[i++]
	
	_amb[2]--
	
	if _amb[2] <= 0 {
		_amb[2] = _amb[1]
		
		if local {
			play_sound_local(_amb[0])
		} else {
			play_sound(_amb[0])
		}
	}
}