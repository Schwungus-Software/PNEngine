/// @description Tick
event_inherited()

var i = 0

repeat array_length(ambience) {
	var _amb = ambience[i++]
	
	_amb[2]--
	
	if _amb[2] <= 0 {
		var _time = _amb[1]
		
		_amb[2] = is_array(_time) ? irandom_range(_time[0], _time[1]) : _time
		
		if local {
			play_sound_local(_amb[0], emitter_falloff, emitter_falloff_max)
		} else {
			play_sound(_amb[0])
		}
	}
}