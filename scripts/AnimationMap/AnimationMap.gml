function AnimationMap() : AssetMap() constructor {
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "animations/" + _name
		var _json = json_load(mod_find_file(_path + ".json"))
		
		if not is_struct(_json) {
			print($"! AnimationMap: '{_name}' has no JSON")
			
			exit
		}
		
		var _ani_file = mod_find_file(_path + ".ani")
		
		if _ani_file == "" {
			print($"! AnimationMap.load: '{_name}' not found")
			
			exit
		}
		
		var _animation = new Animation()
		var _buffer = buffer_load(_ani_file)
		var _bones_n = buffer_read(_buffer, buffer_u8)
		var _keyframes_n = buffer_read(_buffer, buffer_u8)
		
		with _animation {
			name = _name
			type = _json[$ "type"] ?? AnimationTypes.LINEAR
			frames = _json[$ "frames"] ?? 1
			frame_speed = _json[$ "speed"] ?? 1
			
			var j = 0
			
			repeat _bones_n {
				var _dq = array_create(10)
				// The first 8 indices store the dual quaternion
				var k = 0
				
				repeat 8 {
					_dq[@ k] = buffer_read(_buffer, buffer_f32);
					++k
				}
				
				// The 8th index stores the bone's parent
				_dq[@ 8] = buffer_read(_buffer, buffer_u8)
				// The 9th index stores whether or not the bone is attached to its parent
				_dq[@ 9] = buffer_read(_buffer, buffer_u8)
				// The 10th index stores the bone's descendants
				_dq[@ 10] = []
				bind_pose[@ j] = _dq;
				++j
			}
			
			bones_amount = _bones_n
			
			// Fill bones' descendants arrays
			j = 0
			
			repeat _bones_n {
				var _ancestor = j
				var _ancestor_bone = bind_pose[_ancestor]
				
				while _ancestor > 0 {
					_ancestor = _ancestor_bone[8]
					_ancestor_bone = bind_pose[_ancestor]
					array_push(_ancestor_bone[10], j)
				}
				
				++j
			}
			
			ds_grid_resize(keyframes, _keyframes_n, -~_bones_n)
			keyframes_amount = _keyframes_n
			j = 0
			
			repeat _keyframes_n {
				// Load the time of the frame
				keyframes[# j, 0] = buffer_read(_buffer, buffer_f32)
				
				var k = 0
				
				repeat _bones_n {
					// Load the local delta dual quaternion of the frame
					var _dq = dq_build_identity()
					var l = 0
					
					repeat 8 {
						_dq[@ l] = buffer_read(_buffer, buffer_f32);
						++l
					}
					
					keyframes[# j, -~k] = _dq;
					++k
				}
				
				++j
			}
			
			j = 0
			
			repeat frames + (type == AnimationTypes.LINEAR or type == AnimationTypes.QUADRATIC) {
				array_push(samples, create_sample(j / frames));
				++j
			}
		}
		
		buffer_delete(_buffer)
		ds_map_add(assets, _name, _animation)
		print($"AnimationMap: Added '{_name}' ({_animation})")
	}
}

global.animations = new AnimationMap()