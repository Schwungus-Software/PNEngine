enum BoneData {
	RX,
	RY,
	RZ,
	RW,
	DX,
	DY,
	DZ,
	DW,
	PARENT,
	ATTACHED,
	DESCENDANTS,
	__SIZE,
}

enum AnimationTypes {
	LINEAR,
	LINEAR_LOOP,
	QUADRATIC,
	QUADRATIC_LOOP,
}

function Animation() : Asset() constructor {
	bind_poses = ds_map_create()
	
	bones_amount = 0
	keyframes_amount = 0
	keyframes = ds_grid_create(1, 1)
	
	type = AnimationTypes.LINEAR
	frames = 0
	samples = ds_map_create()
	
	frame_speed = 1
	
	static add_bind_pose = function (_animation, _id) {
		if _animation == undefined or ds_map_exists(bind_poses, _id) {
			return false
		}
		
		var _bind_pose = _animation.bind_poses[? ""]
		
		ds_map_add(bind_poses, _id, _bind_pose)
		
		var n = frames + not (type % 2)
		var _samples = array_create(n)
		var j = 0
		
		repeat n {
			_samples[j++] = create_sample(_bind_pose, j / frames)
		}
		
		ds_map_add(samples, _id, _samples)
		print($"Animation.add_bind_pose: Inherited '{_animation.name}' for '{name}' (id: '{_id}')")
		
		return true
	}
	
	static create_sample = function (_bind_pose, _time) {
		static _dwdq = dq_build_identity() // Delta world dual quaternion
		static _wdq = dq_build_identity() // World dual quaternion
		
		var _sample = array_create(bones_amount * 8)
		var _ta, _tb, _tc
		var a = 0
		var b = 0
		var c = 0
		var d = 0
		
		if type == AnimationTypes.QUADRATIC or type == AnimationTypes.QUADRATIC_LOOP {
			var i = 0
			
			repeat keyframes_amount {
				a = i
				b = -~i % keyframes_amount
				c = (i + 2) % keyframes_amount
				_ta = keyframes[# a, 0]
				_tb = keyframes[# b, 0]
				_tc = keyframes[# c, 0]
				
				if type == AnimationTypes.QUADRATIC_LOOP {
					if _time > _tc {
						_tb += _tb < _ta
						_tc += _tc < _tb
					}
					
					_tb -= _tb > _tc
					_ta -= _ta > _tb
				} else {
					if a == keyframes_amount - 2 {
						c = keyframes_amount - 1
						_tc = 1
					}
					
					if a == keyframes_amount - 1 {
						if _time > _tc {
							b = keyframes_amount - 1
							_tb = _ta
							c = b
							_tc = 1
						} else {
							a = 0
							_ta = 0
							b = 0
							_tb = 0
						}
					}
				}

				if _time >= ((_ta + _tb) * 0.5) and _time < ((_tb + _tc) * 0.5) {
					d = _time < _tb ? (_tb == _ta ? 0 : (_time - ((_ta + _tb) * 0.5)) / (_tb - _ta)) : (_tc == _tb ? 1 : 0.5 + (_time - _tb) / (_tc - _tb))
					
					break
				}
				
				++i
			}
			
			_wdq[0] = _bind_pose[0]
			i = 0
			
			var _dq = dq_build_identity()

			repeat bones_amount {
				var _ii = -~i
			    var _qa = keyframes[# a, _ii]
			    var _qb = keyframes[# b, _ii]
			    var _qc = keyframes[# c, _ii]
				
				if quat_dot(_qa, _qb) < 0 {
					dq_invert(_qa, _qa)
				}
				
				if quat_dot(_qb, _qc) < 0 {
					dq_invert(_qc, _qc)
				}
				
				var j = 0
				
			    repeat 8 {
					// Interpolated local orientation
					_dq[j] = sqr(1 - d) * ((_qa[j] + _qb[j]) * 0.5) + 2 * d * (1 - d) * _qb[j] + sqr(d) * ((_qc[j] + _qb[j]) * 0.5);
					++j
				}
				
				dq_normalize(_dq, _dq)
				
				var _bdq = _bind_pose[i]
				var _pdq = _wdq[_bdq[8]]
				
				// Child dual quaternion (_cdq) = Parent dual quaternion (pdq) * Frame dual quaternion (dq)
				var _cdq = [
					_pdq[3] * _dq[0] + _pdq[0] * _dq[3] + _pdq[1] * _dq[2] - _pdq[2] * _dq[1],
					_pdq[3] * _dq[1] + _pdq[1] * _dq[3] + _pdq[2] * _dq[0] - _pdq[0] * _dq[2],
					_pdq[3] * _dq[2] + _pdq[2] * _dq[3] + _pdq[0] * _dq[1] - _pdq[1] * _dq[0],
					_pdq[3] * _dq[3] - _pdq[0] * _dq[0] - _pdq[1] * _dq[1] - _pdq[2] * _dq[2],
					_pdq[3] * _dq[4] + _pdq[0] * _dq[7] + _pdq[1] * _dq[6] - _pdq[2] * _dq[5] + _pdq[7] * _dq[0] + _pdq[4] * _dq[3] + _pdq[5] * _dq[2] - _pdq[6] * _dq[1],
					_pdq[3] * _dq[5] + _pdq[1] * _dq[7] + _pdq[2] * _dq[4] - _pdq[0] * _dq[6] + _pdq[7] * _dq[1] + _pdq[5] * _dq[3] + _pdq[6] * _dq[0] - _pdq[4] * _dq[2],
					_pdq[3] * _dq[6] + _pdq[2] * _dq[7] + _pdq[0] * _dq[5] - _pdq[1] * _dq[4] + _pdq[7] * _dq[2] + _pdq[6] * _dq[3] + _pdq[4] * _dq[1] - _pdq[5] * _dq[0],
					_pdq[3] * _dq[7] - _pdq[0] * _dq[4] - _pdq[1] * _dq[5] - _pdq[2] * _dq[6] + _pdq[7] * _dq[3] - _pdq[4] * _dq[0] - _pdq[5] * _dq[1] - _pdq[6] * _dq[2],
				]
				
			    _wdq[@ i] = _cdq
				
				// Delta world dual quaternion (dwdq) = Child dual quaternion (_cdq) * Bind dual quaternion (_bdq)
				_dwdq[0] = -_cdq[3] * _bdq[0] + _cdq[0] * _bdq[3] - _cdq[1] * _bdq[2] + _cdq[2] * _bdq[1]
				_dwdq[1] = -_cdq[3] * _bdq[1] + _cdq[1] * _bdq[3] - _cdq[2] * _bdq[0] + _cdq[0] * _bdq[2]
				_dwdq[2] = -_cdq[3] * _bdq[2] + _cdq[2] * _bdq[3] - _cdq[0] * _bdq[1] + _cdq[1] * _bdq[0]
				_dwdq[3] = _cdq[3] * _bdq[3] + _cdq[0] * _bdq[0] + _cdq[1] * _bdq[1] + _cdq[2] * _bdq[2]
				_dwdq[4] = -_cdq[3] * _bdq[4] + _cdq[0] * _bdq[7] - _cdq[1] * _bdq[6] + _cdq[2] * _bdq[5] - _cdq[7] * _bdq[0] + _cdq[4] * _bdq[3] - _cdq[5] * _bdq[2] + _cdq[6] * _bdq[1]
				_dwdq[5] = -_cdq[3] * _bdq[5] + _cdq[1] * _bdq[7] - _cdq[2] * _bdq[4] + _cdq[0] * _bdq[6] - _cdq[7] * _bdq[1] + _cdq[5] * _bdq[3] - _cdq[6] * _bdq[0] + _cdq[4] * _bdq[2]
				_dwdq[6] = -_cdq[3] * _bdq[6] + _cdq[2] * _bdq[7] - _cdq[0] * _bdq[5] + _cdq[1] * _bdq[4] - _cdq[7] * _bdq[2] + _cdq[6] * _bdq[3] - _cdq[4] * _bdq[1] + _cdq[5] * _bdq[0]
				_dwdq[7] = _cdq[3] * _bdq[7] + _cdq[0] * _bdq[4] + _cdq[1] * _bdq[5] + _cdq[2] * _bdq[6] +  _cdq[7] * _bdq[3] + _cdq[4] * _bdq[0] + _cdq[5] * _bdq[1] + _cdq[6] * _bdq[2]
				
				// Normalize Delta world dual quaternion
				var _lr = sqrt(sqr(_dwdq[0]) + sqr(_dwdq[1]) + sqr(_dwdq[2]) + sqr(_dwdq[3]))
				
				if _lr < 0.00001 {
					_lr = 1
					_dwdq[0] = 1
					_dwdq[1] = 0
					_dwdq[2] = 0
					_dwdq[3] = 0
				} else {
					_lr = 1 / _lr
				}
				
				_dwdq[0] *= _lr
				_dwdq[1] *= _lr
				_dwdq[2] *= _lr
				_dwdq[3] *= _lr
				
				var _ld = _dwdq[0] * _dwdq[4] + _dwdq[1] * _dwdq[5] + _dwdq[2] * _dwdq[6] + _dwdq[3] * _dwdq[7]
				
				_dwdq[4] = (_dwdq[4] - _dwdq[0] * _ld) * _lr
				_dwdq[5] = (_dwdq[5] - _dwdq[1] * _ld) * _lr
				_dwdq[6] = (_dwdq[6] - _dwdq[2] * _ld) * _lr
				_dwdq[7] = (_dwdq[7] - _dwdq[3] * _ld) * _lr
				
				// Generate sample
				array_copy(_sample, i * 8, _dwdq, 0, 8);
				++i
			}
		} else {
			var f = 0
			
			repeat keyframes_amount {
				if keyframes[# f, 0] >= _time {
					b = f
					
					break
				}
				
				++f
			}
			
			if type == AnimationTypes.LINEAR_LOOP {
				a = (b - 1 + keyframes_amount) % keyframes_amount
			} else {
				if b == 0 {
					b = keyframes_amount - 1
					a = b
				} else {
					a = max(b - 1, 0)
				}
			}
			
			if a != b {
			    var _mb = keyframes[# b, 0]
				var _ma = keyframes[# a, 0]
				
				_mb += _time > _mb
				_ma -= _ma > _mb
				d = _mb == _ma ? 0 : (_time - _ma) / (_mb - _ma)
			}

			_wdq[0] = _bind_pose[0]
			
			var _dq = dq_build_identity()
			var i = 0
			
			repeat bones_amount {
				var _ii = -~i
				var _qa = keyframes[# a, _ii]
			    var _qb = keyframes[# b, _ii]
				
				if quat_dot(_qa, _qb) < 0 {
					smf_dq_invert(_qa, _qa)
				}
				
				dq_lerp(_qa, _qb, d, _dq)
				dq_normalize(_dq, _dq)
				
				var _bdq = _bind_pose[i]
				var _pdq = _wdq[_bdq[8]]
				
				// Child dual quaternion (_cdq) = Parent dual quaternion (pdq) * Frame dual quaternion (dq)
				var _cdq = [
					_pdq[3] * _dq[0] + _pdq[0] * _dq[3] + _pdq[1] * _dq[2] - _pdq[2] * _dq[1],
					_pdq[3] * _dq[1] + _pdq[1] * _dq[3] + _pdq[2] * _dq[0] - _pdq[0] * _dq[2],
					_pdq[3] * _dq[2] + _pdq[2] * _dq[3] + _pdq[0] * _dq[1] - _pdq[1] * _dq[0],
					_pdq[3] * _dq[3] - _pdq[0] * _dq[0] - _pdq[1] * _dq[1] - _pdq[2] * _dq[2],
					_pdq[3] * _dq[4] + _pdq[0] * _dq[7] + _pdq[1] * _dq[6] - _pdq[2] * _dq[5] + _pdq[7] * _dq[0] + _pdq[4] * _dq[3] + _pdq[5] * _dq[2] - _pdq[6] * _dq[1],
					_pdq[3] * _dq[5] + _pdq[1] * _dq[7] + _pdq[2] * _dq[4] - _pdq[0] * _dq[6] + _pdq[7] * _dq[1] + _pdq[5] * _dq[3] + _pdq[6] * _dq[0] - _pdq[4] * _dq[2],
					_pdq[3] * _dq[6] + _pdq[2] * _dq[7] + _pdq[0] * _dq[5] - _pdq[1] * _dq[4] + _pdq[7] * _dq[2] + _pdq[6] * _dq[3] + _pdq[4] * _dq[1] - _pdq[5] * _dq[0],
					_pdq[3] * _dq[7] - _pdq[0] * _dq[4] - _pdq[1] * _dq[5] - _pdq[2] * _dq[6] + _pdq[7] * _dq[3] - _pdq[4] * _dq[0] - _pdq[5] * _dq[1] - _pdq[6] * _dq[2],
				]
				
			    _wdq[i] = _cdq
				
				// Delta world dual quaternion (dwdq) = Child dual quaternion (_cdq) * Bind dual quaternion (bdq)
				_dwdq[0] = -_cdq[3] * _bdq[0] + _cdq[0] * _bdq[3] - _cdq[1] * _bdq[2] + _cdq[2] * _bdq[1]
				_dwdq[1] = -_cdq[3] * _bdq[1] + _cdq[1] * _bdq[3] - _cdq[2] * _bdq[0] + _cdq[0] * _bdq[2]
				_dwdq[2] = -_cdq[3] * _bdq[2] + _cdq[2] * _bdq[3] - _cdq[0] * _bdq[1] + _cdq[1] * _bdq[0]
				_dwdq[3] = _cdq[3] * _bdq[3] + _cdq[0] * _bdq[0] + _cdq[1] * _bdq[1] + _cdq[2] * _bdq[2]
				_dwdq[4] = -_cdq[3] * _bdq[4] + _cdq[0] * _bdq[7] - _cdq[1] * _bdq[6] + _cdq[2] * _bdq[5] - _cdq[7] * _bdq[0] + _cdq[4] * _bdq[3] - _cdq[5] * _bdq[2] + _cdq[6] * _bdq[1]
				_dwdq[5] = -_cdq[3] * _bdq[5] + _cdq[1] * _bdq[7] - _cdq[2] * _bdq[4] + _cdq[0] * _bdq[6] - _cdq[7] * _bdq[1] + _cdq[5] * _bdq[3] - _cdq[6] * _bdq[0] + _cdq[4] * _bdq[2]
				_dwdq[6] = -_cdq[3] * _bdq[6] + _cdq[2] * _bdq[7] - _cdq[0] * _bdq[5] + _cdq[1] * _bdq[4] - _cdq[7] * _bdq[2] + _cdq[6] * _bdq[3] - _cdq[4] * _bdq[1] + _cdq[5] * _bdq[0]
				_dwdq[7] = _cdq[3] * _bdq[7] + _cdq[0] * _bdq[4] + _cdq[1] * _bdq[5] + _cdq[2] * _bdq[6] +  _cdq[7] * _bdq[3] + _cdq[4] * _bdq[0] + _cdq[5] * _bdq[1] + _cdq[6] * _bdq[2]

				// Normalize Delta world dual quaternion
				var _lr = sqrt(sqr(_dwdq[0]) + sqr(_dwdq[1]) + sqr(_dwdq[2]) + sqr(_dwdq[3]))
				
				if _lr < 0.00001 {
					_lr = 1
					_dwdq[0] = 1
					_dwdq[1] = 0
					_dwdq[2] = 0
					_dwdq[3] = 0
				} else {
					_lr = 1 / _lr
				}
				
				_dwdq[0] *= _lr
				_dwdq[1] *= _lr
				_dwdq[2] *= _lr
				_dwdq[3] *= _lr
				
				var _ld = _dwdq[0] * _dwdq[4] + _dwdq[1] * _dwdq[5] + _dwdq[2] * _dwdq[6] + _dwdq[3] * _dwdq[7]
				
				_dwdq[4] = (_dwdq[4] - _dwdq[0] * _ld) * _lr
				_dwdq[5] = (_dwdq[5] - _dwdq[1] * _ld) * _lr
				_dwdq[6] = (_dwdq[6] - _dwdq[2] * _ld) * _lr
				_dwdq[7] = (_dwdq[7] - _dwdq[3] * _ld) * _lr
				
				// Generate sample
				array_copy(_sample, i * 8, _dwdq, 0, 8);
				++i
			}
		}
		
		return _sample
	}
	
	static destroy = function () {
		ds_map_destroy(bind_poses)
		ds_grid_destroy(keyframes)
		ds_map_destroy(samples)
	}
}