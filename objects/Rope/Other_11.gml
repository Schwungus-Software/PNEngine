/// @description Create
event_inherited()

if not is_struct(special) {
	print("! Rope.create: Special properties invalid or not found")
	instance_destroy(id, false)
	
	exit
}

rope_collision = force_type_fallback(special[$ "collision"], "bool", true)
rope_bump = force_type_fallback(special[$ "bump"], "bool", true)

var _x2 = force_type_fallback(special[$ "x2"], "number", x)
var _y2 = force_type_fallback(special[$ "y2"], "number", y)
var _z2 = force_type_fallback(special[$ "z2"], "number", z + 16)

var i = 0
var n = round(force_type_fallback(special[$ "segments"], "number", 8))
var _previous = noone

repeat -~n {
	var a = i++ / n
	var _point = area.add(RopePoint, lerp(x, _x2, a), lerp(y, _y2, a), lerp(z, _z2, a))
	
	array_push(points, _point)
	
	if not instance_exists(_previous) {
		with _point {
			m_bump = MBump.NONE
			pinned = true
		}
		
		_previous = _point
		
		continue
	} else {
		_point.m_bump = rope_bump ? MBump.TO : MBump.NONE
	}
	
	array_push(sticks, new RopeStick(_previous, _point))
	_previous = _point
}