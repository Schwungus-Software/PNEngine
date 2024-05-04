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
		
		tick_sample = dq_build_identity()
		from_sample = dq_build_identity()
		draw_sample = dq_build_identity()
		
		splice_name = ""
		splice = undefined
		splice_bone = -1
		splice_frame = 0
		splice_loop = false
		splice_push = false
		
		static _exclude_sample = []
		
		static set_animation = function (_animation = undefined, _frame = 0, _loop = false) {
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
				
				exit
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
			
			print("Setting " + animation_name)
		}
		
		static set_splice_animation = function (_animation = undefined, _bone = 0, _frame = 0, _loop = false, _push = false) {
			if _frame < 0 and _animation != undefined {
				_frame = _animation.frames
			}
			
			splice_name = _animation == undefined ? "" : _animation.name
			splice = _animation
			splice_finished = false
			splice_bone = _bone
			splice_frame = _frame
			splice_loop = _loop
			splice_push = _push
			interp_skip("ssplice_frame")
		}
		
		static get_point = function (_name, _visual = false) {
			if points == undefined {
				return undefined
			}
			
			var _point = points[$ _name]
			
			if not is_array(_point) {
				return undefined
			}
			
			var _x = _point[0]
			var _y = _point[1]
			var _z = _point[2]
			var _bone = _point[3]
			
			if _bone != -1 {
				var _bone_pos = dq_get_translation(dq_add_translation(get_bone_dq(_bone, _visual), _x, _y, _z))
				
				_x = _bone_pos[0]
				_y = _bone_pos[1]
				_z = _bone_pos[2]
			}
			
			return matrix_transform_point(_visual ? draw_matrix : tick_matrix, _x, _y, _z)
		}
		
		static get_bone_dq = function (_index, _visual = false) {
			static bone_dq = dq_build_identity()
			
			if animation == undefined {
				return bone_dq
			}
			
			return bone_dq
		}
		
		static get_bone_pos = function (_index, _visual = false) {
			var _dq = get_bone_dq(_index, _visual)
			var _pos = dq_get_translation(_dq)
			
			return matrix_transform_point(_visual ? draw_matrix : tick_matrix, _pos[0], _pos[1], _pos[2])
		}
		
		static rotate_bone = function (_index, _x, _y, _z) {}
		
		static splice_animation = function (_animation, _frame, _bone_index, _weight = 1) {}
		
		static splice_sample = function (_sample, _bone_index, _weight = 1, _target_sample = tick_sample) {}
		
		update_sample = undefined
		
		static tick = function (_update_matrix = true) {
			var _update_sample = false
			
			if animation != undefined {
				var _frame_step = frame_speed //* animation.tps
				
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
				splice_frame += 1
				splice_finished = false
				
				if not splice_loop and splice_frame >= splice.frames {
					splice_finished = true
					
					if splice_push {
						splice = undefined
					}
				} else {
					_update_sample = true
				}
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
		alpha = 1
		
		static submit = function () {
			global.u_color.set(color_get_red(color) * COLOR_INVERSE, color_get_green(color) * COLOR_INVERSE, color_get_blue(color) * COLOR_INVERSE, alpha)
			global.u_animated.set(0)
			
			/*if animation == undefined {
				global.u_animated.set(0)
			} else {
				global.u_animated.set(1)
				sample_blend(draw_sample, from_sample, tick_sample, global.tick_draw)
				global.u_bone_dq.set(draw_sample)
			}*/
			
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