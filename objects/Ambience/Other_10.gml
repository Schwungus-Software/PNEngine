/// @description Load
event_inherited()

if not is_struct(special) {
	print("! Ambience.load: Special properties invalid or not found")
	
	exit
}

var _ambience = special[$ "ambience"]

if not is_array(_ambience) {
	show_error($"!!! Ambience.create: Invalid ambience '{_ambience}', expected array", true)
}

var _sounds = global.sounds
var i = array_length(_ambience)

repeat i {
	var _ambient = _ambience[--i]
	
	if not is_struct(_ambient) {
		if is_string(_ambient) {
			_sounds.load(_ambient)
		} else {
			array_delete(_ambience, i, 1)
		}
		
		continue
	}
	
	var _sound = _ambient.sound
	
	if is_array(_sound) {
		var j = 0
		
		repeat array_length(_sound) {
			_sounds.load(_sound[j++])
		}
	} else {
		_sounds.load(_sound)
	}
}