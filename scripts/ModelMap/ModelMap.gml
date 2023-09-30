function ModelMap() : AssetMap() constructor {
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _folder = mod_find_folder("models/" + _name + "/")
		
		if directory_exists(_folder) {
			var _json = json_load(_folder + "model.json")
			
			if _json != undefined {
				var _model = new Model()
				
				#region Submodels
					var _get_submodels = _json[$ "submodels"]
					
					if is_array(_get_submodels) {
						var _submodels = _model.submodels
						var _vbo_format = global.vbo_format
						var _materials = global.materials
						var i = 0
					
						repeat array_length(_get_submodels) {
							var _submodel_info = _get_submodels[i++]
							
							if not is_struct(_submodel_info) {
								show_error($"!!! ModelMap.load: '{_name}' has an invalid submodel definition, expected struct", true)
							}
							
							var _submodel_name = _submodel_info[$ "name"]
						
							if not is_string(_submodel_name) {
								show_error($"!!! ModelMap.load: '{_name}' has invalid submodel name '{_submodel_name}', expected string", true)
							}
							
							var _submodel_filename = _folder + _submodel_name + ".mdl"
							
							if not file_exists(_submodel_filename) {
								show_error($"!!! ModelMap.load: '{_name}' submodel file '{_submodel_filename}' not found", true)
							}
							
							var _submodel = new Submodel()
							var _buffer = buffer_load(_submodel_filename)
							var _vbo = vertex_create_buffer_from_buffer(_buffer, _vbo_format)
							
							buffer_delete(_buffer)
							vertex_freeze(_vbo)
							_submodel.vbo = _vbo
							
							var _submodel_materials = _submodel.materials
							var _get_materials = _submodel_info[$ "materials"]
							
							if not is_array(_get_materials) {
								_materials.load("?")
								array_push(_submodel_materials, _materials.get("?"))
							} else {
								var j = 0
								
								repeat array_length(_get_materials) {
									var _material = _get_materials[j++]
									
									if _material != -1 {
										_materials.load(_material)
										array_push(_submodel_materials, _materials.get(_material))
									}
								}
							}
							
							_submodel.hidden = bool(_submodel_info[$ "hidden"])
							array_push(_submodels, _submodel)
						}
					}
				#endregion
				
				#region Collider
					var _collider_info = _json[$ "collider"]
					
					if is_struct(_collider_info) {
						var _collider = new Collider()
						
						#region Triangles
							var _triangles = _collider.triangles
							var _get_triangles = _collider_info[$ "triangles"]
							var _xmin = infinity
							var _ymin = infinity
							var _xmax = -infinity
							var _ymax = -infinity
						
							if is_array(_get_triangles) {
								var i = 0
							
								repeat array_length(_get_triangles) {
									var _batch = _get_triangles[i++]
								
									if is_struct(_batch) {
										var _batch_name = _batch[$ "batch"]
									
										if not is_string(_batch_name) {
											show_error($"!!! ModelMap.load: '{_name}' has invalid batch name '{_batch_name}', expected string", true)
										}
									
										var _batch_filename = _folder + _batch_name + ".col"
									
										if not file_exists(_batch_filename) {
											show_error($"!!! ModelMap.load: '{_name}' batch file '{_batch_name}' not found", true)
										}
									
										var _batch_surface = _batch[$ "surface"]
									
										if not is_real(_batch_surface) {
											show_error($"!!! ModelMap.load: '{_name}' batch '{_batch_name}' has invalid surface '{_batch_surface}', expected real", true)
										}
									
										_batch_surface = floor(_batch_surface)
									
										var _batch_flags = CollisionFlags.ALL
									
										if not (_batch[$ "collide_body"] ?? true) {
											_batch_flags &= ~CollisionFlags.BODY
										}
									
										if not (_batch[$ "collide_bullet"] ?? true) {
											_batch_flags &= ~CollisionFlags.BULLET
										}
									
										if not (_batch[$ "collide_vision"] ?? true) {
											_batch_flags &= ~CollisionFlags.VISION
										}
									
										if not (_batch[$ "collide_camera"] ?? true) {
											_batch_flags &= ~CollisionFlags.CAMERA
										}
									
										var _batch_layer = _batch[$ "layer"]
										var _batch_mask = 0
									
										switch typeof(_batch_layer) {
											case "undefined":
												_batch_mask = 0xFF
											break
										
											case "real":
												_batch_mask = 1 << _batch_layer
											break
										
											case "array":
												var j = 0
											
												repeat array_length(_batch_layer) {
													_batch_mask |= 1 << _batch_layer[j++]
												}
											break
										
											default:
												show_error($"!!! ModelMap.load: '{_name}' batch '{_batch_name}' has invalid layer '{_batch_layer}', expected real or array", true)
										}
									
										var _buffer = buffer_load(_batch_filename)
									
										repeat buffer_read(_buffer, buffer_u32) {
											var _triangle = array_create(TriangleData.__SIZE)
											var _x1 = buffer_read(_buffer, buffer_f32)
											var _y1 = buffer_read(_buffer, buffer_f32)
											var _z1 = buffer_read(_buffer, buffer_f32)
											var _x2 = buffer_read(_buffer, buffer_f32)
											var _y2 = buffer_read(_buffer, buffer_f32)
											var _z2 = buffer_read(_buffer, buffer_f32)
											var _x3 = buffer_read(_buffer, buffer_f32)
											var _y3 = buffer_read(_buffer, buffer_f32)
											var _z3 = buffer_read(_buffer, buffer_f32)
											
											_xmin = min(_xmin, _x1, _x2, _x3)
											_ymin = min(_ymin, _y1, _y2, _y3)
											_xmax = max(_xmax, _x1, _x2, _x3)
											_ymax = max(_ymax, _y1, _y2, _y3)
											_triangle[TriangleData.X1] = _x1
											_triangle[TriangleData.Y1] = _y1
											_triangle[TriangleData.Z1] = _z1
											_triangle[TriangleData.X2] = _x2
											_triangle[TriangleData.Y2] = _y2
											_triangle[TriangleData.Z2] = _z2
											_triangle[TriangleData.X3] = _x3
											_triangle[TriangleData.Y3] = _y3
											_triangle[TriangleData.Z3] = _z3
											_triangle[TriangleData.NX] = buffer_read(_buffer, buffer_f32)
											_triangle[TriangleData.NY] = buffer_read(_buffer, buffer_f32)
											_triangle[TriangleData.NZ] = buffer_read(_buffer, buffer_f32)
											_triangle[TriangleData.SURFACE] = _batch_surface
											_triangle[TriangleData.FLAGS] = _batch_flags
											_triangle[TriangleData.LAYERS] = _batch_mask
											ds_list_add(_triangles, _triangle)
										}
									
										buffer_delete(_buffer)
									} else {
										show_error($"!!! ModelMap.load: '{_name}' has invalid batch definition, expected struct", true)
									}
								}
							}
						#endregion
						
						#region Layers
							var _active_layers = _batch[$ "active_layers"]
						
							switch typeof(_active_layers) {
								case "undefined":
								break
							
								case "real":
									_collider.layer_mask = 1 << _active_layers
								break
							
								case "array":
									var _mask = 0
									var j = 0
								
									repeat array_length(_batch_layer) {
										_mask |= 1 << _batch_layer[j++]
									}
								
									_collider.layer_mask = _mask
								break
										
								default:
									show_error($"!!! ModelMap.load: '{_name}' collider has invalid active layers '{_active_layers}', expected real or array", true)
							}
						#endregion
						
						#region Subdivision
							with _collider {
								x1 = _xmin
								y1 = _ymin
								x2 = _xmax
								y2 = _ymax
								
								var _width = ceil((_xmax - _xmin) * COLLIDER_REGION_SIZE_INVERSE)
								var _height = ceil((_ymax - _ymin) * COLLIDER_REGION_SIZE_INVERSE)
								var _triangles_n = ds_list_size(triangles)
								
								ds_grid_resize(grid, _width, _height)
								
								var i = 0
								
								repeat _width {
									var j = 0
									
									repeat _height {
										/* Try to create a region for each new grid cell.
										   If there are no triangles in this region, the cell will redirect
										   to noone (empty). */
										var _region = ds_list_create()
										var _rx1 = _xmin + i * COLLIDER_REGION_SIZE
										var _ry1 = _ymin + j * COLLIDER_REGION_SIZE
										var _rx2 = _rx1 + COLLIDER_REGION_SIZE
										var _ry2 = _ry1 + COLLIDER_REGION_SIZE
										var k = 0
										
										repeat _triangles_n {
											var _triangle = triangles[| k++]
				
											var _tx1 = _triangle[TriangleData.X1]
											var _ty1 = _triangle[TriangleData.Y1]
											var _tx2 = _triangle[TriangleData.X2]
											var _ty2 = _triangle[TriangleData.Y2]
											var _tx3 = _triangle[TriangleData.X3]
											var _ty3 = _triangle[TriangleData.Y3]

											// Check if this triangle is within the region.
											// (rectangle_in_triangle doesn't work)
											if point_in_rectangle(_tx1, _ty1, _rx1, _ry1, _rx2, _ry2)
											   or point_in_rectangle(_tx2, _ty2, _rx1, _ry1, _rx2, _ry2)
											   or point_in_rectangle(_tx3, _ty3, _rx1, _ry1, _rx2, _ry2)
											   or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx1, _ry1, _rx2, _ry1)
											   or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx2, _ry1, _rx2, _ry2)
											   or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx2, _ry2, _rx1, _ry2)
											   or lines_intersect(_tx1, _ty1, _tx2, _ty2, _rx1, _ry2, _rx1, _ry1)
											   or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx1, _ry1, _rx2, _ry1)
											   or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx2, _ry1, _rx2, _ry2)
											   or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx2, _ry2, _rx1, _ry2)
											   or lines_intersect(_tx2, _ty2, _tx3, _ty3, _rx1, _ry2, _rx1, _ry1)
											   or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx1, _ry1, _rx2, _ry1)
											   or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx2, _ry1, _rx2, _ry2)
											   or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx2, _ry2, _rx1, _ry2)
											   or lines_intersect(_tx3, _ty3, _tx1, _ty1, _rx1, _ry2, _rx1, _ry1) {
												ds_list_add(_region, _triangle)
											}
										}
										
										if ds_list_empty(_region) {
											ds_list_destroy(_region)
											grid[# i, j] = -1
										} else {
											grid[# i, j] = _region
											ds_list_add(regions, _region)
											ds_list_mark_as_list(regions, ds_list_size(regions) - 1)
										}
										
										++j
									}
									
									++i
								}
							}
						#endregion
						
						_model.collider = _collider
					}
				#endregion
				
				#region Animations
					var _get_animations = _json[$ "animations"]
					
					if is_array(_get_animations) {
						with _model {
							head_bone = _json[$ "head_bone"] ?? -1
							torso_bone = _json[$ "torso_bone"] ?? -1
							hold_bone = _json[$ "hold_bone"] ?? -1
						}
						
						var _animations = _model.animations
						var i = 0
						
						repeat array_length(_get_animations) {
							var _animation_info = _get_animations[i++]
							
							if not is_struct(_animation_info) {
								show_error($"!!! ModelMap.load: '{_name}' has an invalid animation definition, expected struct", true)
							}
							
							var _animation_name = _animation_info[$ "name"]
							
							if not is_string(_animation_name) {
								show_error($"!!! ModelMap.load: '{_name}' has invalid animation name '{_animation_name}', expected string", true)
							}
							
							var _animation_filename = _folder + _animation_name + ".ani"
							
							if not file_exists(_animation_filename) {
								show_error($"!!! ModelMap.load: '{_name}' animation file '{_animation_filename}' not found", true)
							}
							
							var _animation = new Animation()
							var _buffer = buffer_load(_animation_filename)
							var _bones_n = buffer_read(_buffer, buffer_u8)
							var _keyframes_n = buffer_read(_buffer, buffer_u8)
							
							with _animation {
								type = _animation_info[$ "type"] ?? AnimationTypes.LINEAR
								frames = _animation_info[$ "frames"] ?? 1
								frame_speed = _animation_info[$ "speed"] ?? 1
								
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
										_dq = dq_build_identity()
										
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
							array_push(_animations, _animation)
						}
					}
				#endregion
				
				ds_map_add(assets, _name, _model)
				print("ModelMap.load: Added '{0}' ({1})", _name, _model)
			} else {
				print($"! ModelMap.load: '{_name}' is missing model.json")
			}
		} else {
			print($"! ModelMap.load: '{_name}' not found")
		}
	}
}

global.models = new ModelMap()