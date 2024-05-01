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
			print($"! AnimationMap.load: '{_name}' has no data")
			
			exit
		}
		
		var _animation = new Animation()
		
		with _animation {
			name = _name
			type = _json[$ "type"] ?? type
			frames = _json[$ "frames"] ?? frames
			frame_speed = _json[$ "speed"] ?? frame_speed
			
			var _buffer = buffer_load(_ani_file)
			var _bones_n = buffer_read(_buffer, buffer_u8)
			var _keyframes_n = buffer_read(_buffer, buffer_u8)
			var _bind_pose = array_create(_bones_n)
			var i = 0
			
			repeat _bones_n {
				var _dq = array_create(BoneData.__SIZE)
				var j = 0
				
				repeat 8 {
					_dq[j++] = buffer_read(_buffer, buffer_f32)
				}
				
				_dq[BoneData.PARENT] = buffer_read(_buffer, buffer_u8) // Parent bone
				_dq[BoneData.ATTACHED] = buffer_read(_buffer, buffer_u8) // Attached to parent
				_dq[BoneData.DESCENDANTS] = [] // Descendants
				_bind_pose[i] = _dq;
				++i
			}
			
			bones_amount = _bones_n
			
			// Fill bones' descendants arrays
			i = 0
			
			repeat _bones_n {
				var _ancestor = i
				var _ancestor_bone = _bind_pose[_ancestor]
				
				while _ancestor > 0 {
					_ancestor = _ancestor_bone[BoneData.PARENT]
					_ancestor_bone = _bind_pose[_ancestor]
					array_push(_ancestor_bone[BoneData.DESCENDANTS], i)
				}
				
				++i
			}
			
			ds_map_add(bind_poses, "", _bind_pose)
			ds_grid_resize(keyframes, _keyframes_n, -~_bones_n)
			keyframes_amount = _keyframes_n
			i = 0
			
			repeat _keyframes_n {
				keyframes[# i, 0] = buffer_read(_buffer, buffer_f32) // Time
				
				var j = 0
				
				repeat _bones_n {
					// Load the local delta dual quaternion of the frame
					var _dq = dq_build_identity()
					var k = 0
					
					repeat 8 {
						_dq[k++] = buffer_read(_buffer, buffer_f32);
					}
					
					keyframes[# i, ++j] = _dq
				}
				
				++i
			}
			
			buffer_delete(_buffer)
			
			var _play = not (type % 2)
			var n = frames + _play
			var _samples = array_create(n)
			var j = 0
			
			repeat n {
				_samples[j] = create_sample(_bind_pose, j / frames);
				++j
			}
			
			if _play {
				array_push(_samples, array_shift(_samples))
			}
			
			ds_map_add(samples, "", _samples)
		}
		
		ds_map_add(assets, _name, _animation)
		print($"AnimationMap: Added '{_name}'")
	}

	static inject = function (_target, _source, _id) {
		var _parent = fetch(_target)
		
		if _parent == undefined {
			return false
		}
		
		var _child = fetch(_source)
		
		if _child == undefined {
			return false
		}
		
		return _parent.add_bind_pose(_child, _id)
	}
}

global.animations = new AnimationMap()