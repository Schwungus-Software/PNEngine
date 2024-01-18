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
		
		var _parent = undefined
		var _pname = _json[$ "parent"]
		
		if is_string(_pname) and _pname != _name {
			_parent = fetch(_pname)
			
			if _parent == undefined {
				print($"! AnimationMap.load: '{_name}' parent '{_pname}' not found")
			}
		}
		
		var _base = undefined
		var _bname = _json[$ "base"]
		
		if is_string(_bname) and _bname != _name {
			_base = fetch(_pname)
			
			if _base == undefined {
				print($"! AnimationMap.load: '{_name}' base '{_bname}' not found")
			}
		}
		
		var _ani_file = mod_find_file(_path + ".ani")
		
		if _ani_file == "" and _base == undefined and _parent == undefined {
			print($"! AnimationMap.load: '{_name}' has no data")
			
			exit
		}
		
		var _animation = new Animation()
		
		if _parent != undefined {
			with _animation {
				type = _parent.type
				frames = _parent.frames
				frame_speed = _parent.frame_speed
				
				if _ani_file == "" {
					bones_amount = _parent.bones_amount
					keyframes_amount = _parent.keyframes_amount
					ds_grid_destroy(keyframes)
					keyframes = _parent.keyframes
					bind_pose = _parent.bind_pose
				}
			}
		}
		
		with _animation {
			if _base != undefined {
				bones_amount = _base.bones_amount
				bind_pose = _base.bind_pose
				
				if _ani_file == "" and _parent == undefined {
					type = _base.type
					frames = _base.frames
					frame_speed = _base.frame_speed
					keyframes_amount = _base.keyframes_amount
					ds_grid_destroy(keyframes)
					keyframes = _base.keyframes
				}
			}
			
			name = _name
			type = _json[$ "type"] ?? type
			frames = _json[$ "frames"] ?? frames
			frame_speed = _json[$ "speed"] ?? frame_speed
		}
		
		if _ani_file != "" and _parent == undefined {
			var _buffer = buffer_load(_ani_file)
			var _bones_n = buffer_read(_buffer, buffer_u8)
			var _keyframes_n = buffer_read(_buffer, buffer_u8)
			
			with _animation {
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
			}
			
			buffer_delete(_buffer)
		}
		
		with _animation {
			var j = 0
			
			repeat frames + not (type % 2) {
				array_push(samples, create_sample(j / frames));
				++j
			}
		}
		
		ds_map_add(assets, _name, _animation)
		print($"AnimationMap: Added '{_name}'")
	}
}

global.animations = new AnimationMap()