/// @description Create
event_inherited()

f_sync = false

var _samb = special[$ "ambience"]

if not is_array(_samb) {
	destroy()
	
	exit
}

var i = array_length(_samb)

array_copy(ambience, 0, _samb, 0, i)
local = special[$ "local"] ?? false
emitter_falloff = special[$ "falloff"] ?? 0
emitter_falloff_max = special[$ "falloff_max"] ?? 360
emitter_falloff_factor = special[$ "falloff_factor"] ?? 1

var _sounds = global.sounds

repeat i {
	var _ambient = ambience[--i]
	
	if is_string(_ambient) {
		_ambient = _sounds.get(_ambient)
		
		if local {
			play_sound_local(_ambient, true)
		} else {
			play_sound(_ambient, true)
		}
		
		array_delete(ambience, i, 1)
		
		continue
	}
	
	var _amb = array_create(3)
	var _ssnd = _ambient.sound
	var _snd
	
	if is_array(_ssnd) {
		var j = 0
		var n2 = array_length(_ssnd)
		
		_snd = array_create(n2)
		
		repeat n2 {
			_snd[j] = _sounds.get(_ssnd[j]);
			++j
		}
	} else {
		_snd = _sounds.get(_ssnd)
	}
	
	_amb[0] = _snd
	_amb[1] = _ambient.time * TICKRATE
	ambience[i] = _amb
}