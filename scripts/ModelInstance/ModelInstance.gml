function ModelInstance(_model, _x = 0, _y = 0, _z = 0, _yaw = 0, _pitch = 0, _roll = 0, _scale = 1, _x_scale = 1, _y_scale = 1, _z_scale = 1) constructor {
	model = _model
	submodels = _model.submodels
	
	var n = array_length(submodels)
	var i = 0
	
	submodels_amount = n
	skins = array_create(n)
	
	repeat n {
		if submodels[i].hidden {
			skins[i] = -1
		}
		
		++i
	}
	
	skins_updated = true
	override_textures = array_create(n, undefined)
	cache = []
	cache_amount = 0
	
	head_bone = _model.head_bone
	torso_bone = _model.torso_bone
	hold_bone = _model.hold_bone
	
	hold_offset_matrix = _model.hold_offset_matrix
	points = _model.points
	
	static set_skin = function (_submodel, _skin) {
		gml_pragma("forceinline")
		
		if skins[_submodel] != _skin {
			skins[_submodel] = _skin
			skins_updated = true
		}
	}
	
	static override_texture = function (_submodel, _texture) {
		gml_pragma("forceinline")
		
		if override_textures[_submodel] != _texture {
			override_textures[_submodel] = _texture
			skins_updated = true
		}
	}
	
	#region Animation
		animated = false
		animation_name = ""
		animation = undefined
		animation_loop = false
		animation_finished = false
		animation_state = 0
		frame = 0
		frame_speed = 1
		
		transition = 0
		transition_duration = 0
		transition_frame = undefined
		
		node_transforms = []
		node_post_rotations = undefined
		node_scales = undefined
		tick_sample = []
		from_sample = []
		draw_sample = []
		
		splice_name = ""
		splice = undefined
		splice_branch = undefined
		splice_loop = false
		splice_finished = false
		splice_state = 0
		splice_frame = 0
		splice_speed = 1
		
		static output_to_sample = function (_sample) {
			static _transframe = []
			
			var _duration = animation.duration
			var _frame, _next_frame
			
			if animation_loop {
				_frame = frame % _duration
				_next_frame = (frame + 1) % _duration
			} else {
				var _last_frame = _duration - 1
				
				_frame = min(frame, _last_frame)
				_next_frame = min(frame + 1, _last_frame)
			}
			
			var _parent_frames = animation.parent_frames
			
			dq_lerp_array(_parent_frames[_frame], _parent_frames[_next_frame], frac(frame), _transframe)
			
			if transition < transition_duration {
				dq_slerp_array(transition_frame, _transframe, transition / transition_duration, _transframe)
			}
			
			if not (splice == undefined or splice_branch == undefined) {
				with splice {
					_parent_frames = parent_frames
					_duration = duration
				}
				
				var _splice_data = _parent_frames[splice_loop ? (splice_frame % _duration) : min(splice_frame, _duration - 1)]
				var i = 0
				
				repeat array_length(splice_branch) {
					var _offset = splice_branch[i++] * 8
					
					array_copy(_transframe, _offset, _splice_data, _offset, 8)
				}
			}
			
			var _bone_offsets, _node_count, _root_node
			
			with model {
				_bone_offsets = bone_offsets
				_node_count = nodes_amount
				_root_node = root_node
			}
			
			static _node_stack = []
			
			if array_length(_node_stack) < _node_count {
				array_resize(_node_stack, _node_count)
			}
			
			_node_stack[0] = _root_node
			
			var _stack_next = 1
			
			repeat _node_count {
				if _stack_next == 0 {
					break
				}
				
				var _node = _node_stack[--_stack_next]
				
				// TODO: Separate skeleton from the rest of the nodes to save on
				// iterations here.
				
				var _node_index = _node.index
				var _node_offset = _node_index * 8
				var _node_post_rotation = node_post_rotations[_node_index]
				var _node_parent = _node.parent
				var _parent_index = (_node_parent != undefined) ? _node_parent.index : -1
				
				if _node_post_rotation != undefined {
					static _npr_dq = new BBMOD_DualQuaternion()
					
					_npr_dq.FromArray(_transframe, _node_offset)
					
					var _position = _npr_dq.GetTranslation()
					var _rotation = _npr_dq.GetRotation()
					
					_rotation.MulSelf(new BBMOD_Quaternion().FromArray(_node_post_rotation))
					_npr_dq.FromTranslationRotation(_position, _rotation)
					
					if _parent_index != -1 {
						_npr_dq.MulSelf(new BBMOD_DualQuaternion().FromArray(node_transforms, _parent_index * 8))
					}
					
					_npr_dq.ToArray(node_transforms, _node_offset)
				} else {
					if _parent_index == -1 {
						// No parent transform -> just copy the node transform
						array_copy(node_transforms, _node_offset, _transframe, _node_offset, 8)
					} else {
						// Multiply node transform with parent's transform
						dq_multiply_array(_transframe, _node_offset, node_transforms, _parent_index * 8, node_transforms, _node_offset)
					}
				}
				
				if _node.is_bone {
					dq_multiply_array(_bone_offsets, _node_offset, node_transforms, _node_offset, _sample, _node_offset)
				}
				
				var _children = _node.children
				var i = 0
				
				repeat array_length(_children) {
					_node_stack[_stack_next++] = _children[i++]
				}
			}
			
			return _sample
		}
		
		static set_animation = function (_animation = undefined, _frame = 0, _loop = false, _time = 0) {
			if _animation == undefined {
				animation_name = ""
				animation = undefined
				animation_loop = _loop
				animation_finished = false
				animation_state = 0
				
				if _frame >= 0 {
					frame = _frame
				}
				
				frame_speed = 1
				transition = 0
				transition_duration = 0
				
				exit
			}
			
			var _transitioning = false
			
			transition = 0
			transition_duration = _time
			
			if _time > 0 and animation != undefined {
				var _duration = animation.duration
				
				transition_frame = animation.parent_frames[animation_loop ? (frame % _duration) : min(frame, _duration - 1)]
				_transitioning = true
			}
			
			animation_name = _animation.name
			animation = _animation
			animation_loop = _loop
			animation_finished = false
			animation_state = 0
			
			if _frame >= 0 {
				frame = _frame
				frame_speed = 1
			}
			
			if not animated {
				var n = model.nodes_amount
				
				node_post_rotations = array_create(n, undefined)
				node_scales = array_create(n, undefined)
				animated = true
			}
			
			if not _transitioning {
				output_to_sample(tick_sample)
				array_copy(from_sample, 0, tick_sample, 0, array_length(tick_sample))
			}
		}
		
		static set_splice_animation = function (_animation = undefined, _branch = undefined, _frame = 0, _loop = false) {
			if _frame < 0 and _animation != undefined {
				_frame = _animation.duration - 1
			}
			
			splice_name = _animation == undefined ? "" : _animation.name
			splice = _animation
			splice_branch = _branch
			splice_frame = _frame
			splice_loop = _loop
			splice_finished = false
			splice_state = 0
			splice_speed = 1
			output_to_sample(tick_sample)
			array_copy(from_sample, 0, tick_sample, 0, array_length(tick_sample))
		}
		
		static get_node = function (_id) {
			gml_pragma("forceinline")
			
			return model.get_node(_id)
		}
		
		static get_node_id = function (_id) {
			gml_pragma("forceinline")
			
			return model.get_node_id(_id)
		}
		
		static get_branch = function (_id) {
			gml_pragma("forceinline")
			
			return model.get_branch(_id)
		}
		
		static get_branch_id = function (_id) {
			gml_pragma("forceinline")
			
			return model.get_branch_id(_id)
		}
		
		static get_point = function (_name, _visual = false) {
			var _point = points[$ _name]
			var _x = _point[0]
			var _y = _point[1]
			var _z = _point[2]
			var _node = _point[3]
			
			if _node != undefined {
				var _node_pos = dq_transform_point(get_node_dq(_node.index), _x, _y, _z)
				
				_x = _node_pos[0]
				_y = _node_pos[1]
				_z = _node_pos[2]
			}
			
			return matrix_transform_point(_visual ? draw_matrix : tick_matrix, _x, _y, _z)
		}
		
		static get_node_dq = function (_index) {
			gml_pragma("forceinline")
			
			static node_dq = dq_build_identity()
			
			var i = _index * 8
			
			node_dq[0] = node_transforms[i]
			node_dq[1] = node_transforms[-~i]
			node_dq[2] = node_transforms[i + 2]
			node_dq[3] = node_transforms[i + 3]
			node_dq[4] = node_transforms[i + 4]
			node_dq[5] = node_transforms[i + 5]
			node_dq[6] = node_transforms[i + 6]
			node_dq[7] = node_transforms[i + 7]
			
			return node_dq
		}
		
		static get_node_pos = function (_index, _visual = false) {
			gml_pragma("forceinline")
			
			var _pos = dq_get_translation(get_node_dq(_index))
			
			return matrix_transform_point(_visual ? draw_matrix : tick_matrix, _pos[0], _pos[1], _pos[2])
		}
		
		static post_rotate_node = function (_index, _x, _y, _z) {
			var _quat = node_post_rotations[_index]
			
			if _quat == undefined {
				_quat = quat_build()
				node_post_rotations[_index] = _quat
			}
			
			quat_build_euler(_x, _y, _z, _quat)
			
			return _quat
		}
		
		static post_rotate_node_quat = function (_index, _quat) {
			gml_pragma("forceinline")
			
			node_post_rotations[_index] = _quat
			
			return _quat
		}
		
		static scale_node = function (_index, _x, _y, _z) {
			var _vec3 = node_scales[_index]
			
			if _vec3 == undefined {
				_vec3 = array_create(3)
				node_scales[_index] = _vec3
			}
			
			_vec3[0] = _x
			_vec3[1] = _y
			_vec3[2] = _z
			
			return _vec3
		}
		
		static scale_node_vec3 = function (_index, _vec3) {
			gml_pragma("forceinline")
			
			node_scales[_index] = _vec3
			
			return _vec3
		}
		
		static tick = function (_update_matrix = true) {
			var _update_sample = false
			
			if animation != undefined {
				var _frame_step = frame_speed * animation.frame_speed
				
				animation_finished = false
				
				if animation_loop {
					// Looping animation
					frame += _frame_step
				} else {
					// Animation plays only once
					var _frames = animation.duration - 1
					
					frame = clamp(frame + _frame_step, 0, _frames)
					animation_finished = frame >= _frames
				}
				
				_update_sample = true
			}
			
			if splice != undefined {
				var _frame_step = splice_speed * animation.frame_speed
				
				splice_frame += _frame_step
				splice_finished = false
				
				if not splice_loop and splice_frame >= (splice.duration - 1) {
					splice_finished = true
				} else {
					_update_sample = true
				}
			}
			
			if transition < transition_duration {
				++transition
				_update_sample = true
			}
			
			if _update_sample {
				array_copy(from_sample, 0, tick_sample, 0, array_length(tick_sample))
				output_to_sample(tick_sample)
			}
			
			if _update_matrix {
				tick_matrix = matrix_build(x, y, z, roll, pitch, yaw, scale * x_scale, scale * y_scale, scale * z_scale)
			}
		}
	#endregion
	
	#region Transform
		tick_matrix = matrix_build(_x, _y, _z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale)
		draw_matrix = matrix_build(_x, _y, _z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale)
		
		x = _x
		y = _y
		z = _z
		
		yaw = _yaw
		pitch = _pitch
		roll = _roll
		
		scale = _scale
		x_scale = _x_scale
		y_scale = _y_scale
		z_scale = _z_scale
		
		interp("x", "sx")
		interp("y", "sy")
		interp("z", "sz")
		
		interp("yaw", "syaw", true)
		interp("pitch", "spitch", true)
		interp("roll", "sroll", true)
		
		interp("scale", "sscale")
		interp("x_scale", "sx_scale")
		interp("y_scale", "sy_scale")
		interp("z_scale", "sz_scale")
		
		static move = function (_x, _y, _z) {
			x = _x
			y = _y
			z = _z
			interp_skip("sx")
			interp_skip("sy")
			interp_skip("sz")
			
			return self
		}
		
		static rotate = function (_yaw, _pitch, _roll) {
			yaw = _yaw
			pitch = _pitch
			roll = _roll
			interp_skip("syaw")
			interp_skip("spitch")
			interp_skip("sroll")
			
			return self
		}
		
		static resize = function (_scale, _x_scale = x_scale, _y_scale = y_scale, _z_scale = z_scale) {
			scale = _scale
			x_scale = _x_scale
			y_scale = _y_scale
			z_scale = _z_scale
			interp_skip("sscale")
			interp_skip("sx_scale")
			interp_skip("sy_scale")
			interp_skip("sz_scale")
			
			return self
		}
	#endregion
	
	#region Rendering
		visible = true
		color = c_white
		blendmode = bm_normal
		alpha = 1
		
		static submit = function () {
			var _blendmode = gpu_get_blendmode()
			
			global.u_color.set(color_get_red(color) * COLOR_INVERSE, color_get_green(color) * COLOR_INVERSE, color_get_blue(color) * COLOR_INVERSE, alpha)
			
			if shader_current() == shSky and blendmode == bm_normal {
				gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one)
			} else {
				gpu_set_blendmode(blendmode)
			}
			
			if animation == undefined {
				global.u_animated.set(0)
			} else {
				global.u_animated.set(1)
				dq_lerp_array(from_sample, tick_sample, global.tick_draw, draw_sample)
				global.u_bone_dq.set(draw_sample)
			}
			
			var _current_shader = global.current_shader
			var _u_material_bright = global.u_material_bright
			var _u_material_specular = global.u_material_specular
			var _u_material_wind = global.u_material_wind
			var _u_material_color = global.u_material_color
			var _u_material_alpha_test = global.u_material_alpha_test
			var _u_material_scroll = global.u_material_scroll
			var _u_material_can_blend = global.u_material_can_blend
			var _u_material_blend = global.u_material_blend
			var _u_material_blend_uvs = global.u_material_blend_uvs
			var _u_uvs = global.u_uvs
			
			if skins_updated {
				var i = 0
				var j = 0
				var k = 0
				
				var _cache = cache
				var _override_textures = override_textures
				
				repeat submodels_amount {
					var _skin = skins[i]
					
					if _skin == -1 {
						++i
						
						continue
					}
					
					with submodels[i] {
						_cache[j] = vbo
						
						var _material = materials[_skin]
						
						_cache[-~j] = _material
						
						var _texture = _override_textures[i]
						
						if not CollageIsImage(_texture) and not CanvasIsCanvas(_texture) {
							_texture = _material.image
						}
						
						_cache[j + 2] = _texture
					}
					
					++i
					j += 3;
					++k
				}
				
				array_resize(_cache, j)
				cache_amount = k
				skins_updated = false
			}
			
			var i = 0
			
			repeat cache_amount {
				var _vbo = cache[i]
				var _material = cache[-~i]
				var _texture = cache[i + 2]
				
				var _idx = _material.frame_speed * current_time
				
				with _material {
					if CollageIsImage(image2) {
						_u_material_can_blend.set(1)
						
						if image2 == -1 {
							_u_material_blend.set(-1)
						} else {
							_u_material_blend.set(image2.GetTexture(_idx))
							
							var _uvs = image2.GetUVs(_idx)
							
							with _uvs {
								_u_material_blend_uvs.set(normLeft, normTop, normRight, normBottom)
							}
						}
					} else {
						_u_material_can_blend.set(0)
					}
					
					_u_material_bright.set(bright)
					_u_material_specular.set(specular, specular_exponent)
					_u_material_wind.set(wind, wind_lock_bottom, wind_speed)
					_u_material_color.set(color[0], color[1], color[2], color[3])
				}
				
				with _material {
					_u_material_alpha_test.set(alpha_test)
					_u_material_scroll.set(x_scroll, y_scroll)
				}
				
				if CollageIsImage(_texture) {
					with _texture.GetUVs(_idx) {
						_u_uvs.set(normLeft, normTop, normRight, normBottom)
					}
					
					_texture = _texture.GetTexture(_idx)
				} else if CanvasIsCanvas(_texture) {
					_u_uvs.set(0, 0, 1, 1)
					_texture = _texture.GetTexture()
				}
				
				vertex_submit(_vbo, pr_trianglelist, _texture)
				i += 3
			}
			
			gpu_set_blendmode(_blendmode)
		}
		
		static draw = function () {
			var _mwp = matrix_get(matrix_world)
			
			draw_matrix = matrix_build(sx, sy, sz, sroll, spitch, syaw, sscale * sx_scale, sscale * sy_scale, sscale * sz_scale)
			matrix_set(matrix_world, draw_matrix)
			submit()
			matrix_set(matrix_world, _mwp)
		}
	#endregion
}