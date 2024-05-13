/// @description Tick
var _rope_collision = rope_collision

var _x = x
var _y = y
var _z = z
var _x_start = x_start
var _y_start = y_start
var _z_start = z_start

var _gravity = area.gravity * grav * 4
var i = 0
var _previous = noone

repeat array_length(points) {
	with points[i++] {
		if pinned {
			x = _x + (x_start - _x_start)
			y = _y + (y_start - _y_start)
			z = _z + (z_start - _z_start)
			_previous = id
			
			break
		}
		
		var _vx = (x - x_previous) * 0.999
		var _vy = (y - y_previous) * 0.999
		var _vz = (z - z_previous) * 0.999
		
		x_previous = x
		y_previous = y
		z_previous = z
		
		if _rope_collision {
			var _ray = raycast(_previous.x, _previous.y, _previous.z, x + _vx, y + _vy, z + _vz + _gravity, CollisionFlags.BODY)
		
			x = _ray[RaycastData.X] 
			y = _ray[RaycastData.Y]
			z = _ray[RaycastData.Z]
		
			if _ray[RaycastData.HIT] {
				x += _ray[RaycastData.NX] * 0.01
				y += _ray[RaycastData.NY] * 0.01
				z += _ray[RaycastData.NZ] * 0.01
			}
		} else {
			x += _vx
			y += _vy
			z += _vz + _gravity
		}
		
		_previous = id
	}
}

var n = array_length(sticks)

repeat 3 {
	i = 0

	repeat n {
		with sticks[i++] {
			var _dx = point2.x - point1.x
			var _dy = point2.y - point1.y
			var _dz = point2.z - point1.z
			
			var _dist = point_distance_3d(0, 0, 0, _dx, _dy, _dz)
			var _diff = length - _dist
			var _percent = _diff / _dist * 0.5
			
			var _xoffs = _dx * _percent
			var _yoffs = _dy * _percent
			var _zoffs = _dz * _percent
			
			with point1 {
				if not pinned {
					if _rope_collision {
						var _ray = raycast(x, y, z, x - _xoffs, y - _yoffs, z - _zoffs, CollisionFlags.BODY)
					
						x = _ray[RaycastData.X]
						y = _ray[RaycastData.Y]
						z = _ray[RaycastData.Z]
					
						if _ray[RaycastData.HIT] {
							x += _ray[RaycastData.NX] * 0.01
							y += _ray[RaycastData.NY] * 0.01
							z += _ray[RaycastData.NZ] * 0.01
						}
					} else {
						x -= _xoffs
						y -= _yoffs
						z -= _zoffs
					}
				}
			}
			
			with point2 {
				if not pinned {
					if _rope_collision {
						var _ray = raycast(x, y, z, x + _xoffs, y + _yoffs, z + _zoffs, CollisionFlags.BODY)
					
						x = _ray[RaycastData.X]
						y = _ray[RaycastData.Y]
						z = _ray[RaycastData.Z]
					
						if _ray[RaycastData.HIT] {
							x += _ray[RaycastData.NX] * 0.01
							y += _ray[RaycastData.NY] * 0.01
							z += _ray[RaycastData.NZ] * 0.01
						}
					} else {
						x += _xoffs
						y += _yoffs
						z += _zoffs
					}
				}
			}
		}
	}
}

event_inherited()