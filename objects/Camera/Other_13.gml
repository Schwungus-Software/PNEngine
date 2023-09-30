/// @description Tick
event_inherited()

var _targets = ds_map_size(targets)

if _targets {
	var _range = 0
	var _x = 0
	var _y = 0
	var _z = 0
	
	var _key = ds_map_find_last(targets)
	
	repeat _targets {
		var _target = targets[? _key]
		
		if is_array(_key) {
			_x += _key[0]
			_y += _key[1]
			_z += _key[2]
		} else {
			if instance_exists(_key) {
				_x += _key.x
				_y += _key.y
				_z += _key.z
			} else {
				ds_map_delete(targets, _key)
				
				continue
			}
		}
		
		_range += _target[CameraTargetData.RANGE]
		_x += _target[CameraTargetData.X_OFFSET]
		_y += _target[CameraTargetData.Y_OFFSET]
		_z += _target[CameraTargetData.Z_OFFSET]
		
		_key = ds_map_find_previous(targets, _key)
	}
	
	var _targets_inv = 1 / _targets
	
	_range *= _targets_inv
	_x *= _targets_inv
	_y *= _targets_inv
	_z *= _targets_inv
	
	var _nz = dcos(pitch)
	
	range = _range
	x = _x - lengthdir_x(_range, yaw) * _nz
	y = _y - lengthdir_y(_range, yaw) * _nz
	z = _z + lengthdir_y(_range, pitch)
}