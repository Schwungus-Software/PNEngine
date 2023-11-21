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
	
	head_bone = _model.head_bone
	torso_bone = _model.torso_bone
	hold_bone = _model.hold_bone
	
	#region Animation
		animation_name = ""
		animation = undefined
		animation_finished = false
		frame = 0
		frame_speed = 1
		sample = dq_build_identity()
		interp("frame", "sframe")
		
		transition = 0
		transition_time = 0
		transition_sample = dq_build_identity()
		transition_sample2 = dq_build_identity()
		interp("transition", "stransition")
		
		static set_animation = function (_animation, _frame = 0, _time = 0) {
			if _animation == undefined {
				animation_name = ""
				animation = undefined
				
				return true
			}
			
			animation_name = _animation.name
			animation = _animation
			
			if _frame >= 0 {
				frame = _frame
				interp_skip("sframe")
				frame_speed = 1
				
				var _copy_sample = _animation.samples[_frame % _animation.frames]
				
				array_copy(sample, 0, _copy_sample, 0, array_length(_copy_sample))
			}
			
			var _transition_previous = transition < transition_time
			
			transition = 0
			interp_skip("stransition")
			transition_time = _time
			
			if _time > 0 {
				var _final_sample = _transition_previous ? transition_sample2 : sample
				
				array_copy(transition_sample, 0, _final_sample, 0, array_length(_final_sample))
			}
			
			return true
		}
		
		static get_bone_dq = function (_index) {
			static bone_dq = dq_build_identity()
			
			if animation == undefined {
				return bone_dq
			}
			
			/* Returns the world orientation of the node as a dual quaternion.
			   targetQ is an optional argument, in case you'd like to output directly to an
			   existing dual quaternion.
			   If targetQ is not provided, a new dual quaternion is created. */
			
			var b = 8 * _index
			var s = animation.bind_pose[_index]
			var r3 = sample[b + 3]
			var r4 = sample[b + 4]
			var r5 = sample[b + 5]
			var r6 = sample[b + 6]
			
			if r3 == 1 and r4 == 0 and r5 == 0 and r6 == 0 {
				/* An early out if this bone has not been transformed, letting us skip a dual
				   quaternion multiplication */
				array_copy(bone_dq, 0, s, 0, 8)
		
				return bone_dq
			}
			
			var r0 = sample[b]
			var r1 = sample[-~b]
			var r2 = sample[b + 2]
			var r7 = sample[b + 7]
			
			var s0 = s[0]
			var s1 = s[1]
			var s2 = s[2]
			var s3 = s[3]
			var s4 = s[4]
			var s5 = s[5]
			var s6 = s[6]
			var s7 = s[7]
			
			bone_dq[0] = r3 * s0 + r0 * s3 + r1 * s2 - r2 * s1
			bone_dq[1] = r3 * s1 + r1 * s3 + r2 * s0 - r0 * s2
			bone_dq[2] = r3 * s2 + r2 * s3 + r0 * s1 - r1 * s0
			bone_dq[3] = r3 * s3 - r0 * s0 - r1 * s1 - r2 * s2
			bone_dq[4] = r3 * s4 + r0 * s7 + r1 * s6 - r2 * s5 + r7 * s0 + r4 * s3 + r5 * s2 - r6 * s1
			bone_dq[5] = r3 * s5 + r1 * s7 + r2 * s4 - r0 * s6 + r7 * s1 + r5 * s3 + r6 * s0 - r4 * s2
			bone_dq[6] = r3 * s6 + r2 * s7 + r0 * s5 - r1 * s4 + r7 * s2 + r6 * s3 + r4 * s1 - r5 * s0
			bone_dq[7] = r3 * s7 - r0 * s4 - r1 * s5 - r2 * s6 + r7 * s3 - r4 * s0 - r5 * s1 - r6 * s2
			
			return bone_dq
		}
		
		static rotate_bone = function (_index, _x, _y, _z) {
			/* This script lets you modify a sample.
			   This is useful for head turning and procedural animations.
			   The bone will rotate around its parent's position. */
			
			var _bind_pose = animation.bind_pose
			var _bone = _bind_pose[_index]
			var _dq = get_bone_dq(_bone[8])
			
			/* Find the pivot position (position of the root of the bone, typically at the
			   parent's position). Contents copied from dq_get_translation */
			var _q0 = _dq[0]
			var _q1 = _dq[1]
			var _q2 = _dq[2]
			var _q3 = _dq[3]
			var _q4 = _dq[4]
			var _q5 = _dq[5]
			var _q6 = _dq[6]
			var _q7 = _dq[7]
			
			var _px = 2 * (-_q7 * _q0 + _q4 * _q3 + _q6 * _q1 - _q5 * _q2)
			var _py = 2 * (-_q7 * _q1 + _q5 * _q3 + _q4 * _q2 - _q6 * _q0)
			var _pz = 2 * (-_q7 * _q2 + _q6 * _q3 + _q5 * _q0 - _q4 * _q1)
			
			// Create the transformation dual quat
			var _xrad = degtorad(_x)
			var _yrad = degtorad(_y)
			var _zrad = degtorad(_z)
			
			var _xsin = sin(.5 * _xrad)
			var _xcos = cos(.5 * _xrad)
			var _ysin = sin(.5 * _yrad)
			var _ycos = cos(.5 * _yrad)
			var _zsin = sin(.5 * _zrad)
			var _zcos = cos(.5 * _zrad)
			
			var _r0 = _zcos * _xsin * _ycos - _zsin * _xcos * _ysin
			var _r1 = _zcos * _xcos * _ysin + _zsin * _xsin * _ycos
			var _r2 = _zcos * _xsin * _ysin + _zsin * _xcos * _ycos
			var _r3 = _zcos * _xcos * _ycos - _zsin * _xsin * _ysin
			var _r4 = _py * _r2 - _pz * _r1
			var _r5 = _pz * _r0 - _px * _r2
			var _r6 = _px * _r1 - _py * _r0
			
			// Transform this node and all its descendants
			var _descendants = _bone[10]
			var b = _index
			var i = array_length(_descendants)
			
			while true {
				if b >= 0 {
					b *= 8
					
					var _b1 = -~b
					var _b2 = b + 2
					var _b3 = b + 3
					var _b4 = b + 4
					var _b5 = b + 5
					var _b6 = b + 6
					var _b7 = b + 7
					
					var _s0 = sample[b]
					var _s1 = sample[_b1]
					var _s2 = sample[_b2]
					var _s3 = sample[_b3]
					var _s4 = sample[_b4]
					var _s5 = sample[_b5]
					var _s6 = sample[_b6]
					var _s7 = sample[_b7]
					
					sample[b] = _r3 * _s0 + _r0 * _s3 + _r1 * _s2 - _r2 * _s1
					sample[_b1] = _r3 * _s1 - _r0 * _s2 + _r1 * _s3 + _r2 * _s0
					sample[_b2] = _r3 * _s2 + _r0 * _s1 - _r1 * _s0 + _r2 * _s3
					sample[_b3] = _r3 * _s3 - _r0 * _s0 - _r1 * _s1 - _r2 * _s2
					sample[_b4] = _r3 * _s4 + _r0 * _s7 + _r1 * _s6 - _r2 * _s5 + _r4 * _s3 + _r5 * _s2 - _r6 * _s1
					sample[_b5] = _r3 * _s5 - _r0 * _s6 + _r1 * _s7 + _r2 * _s4 - _r4 * _s2 + _r5 * _s3 + _r6 * _s0
					sample[_b6] = _r3 * _s6 + _r0 * _s5 - _r1 * _s4 + _r2 * _s7 + _r4 * _s1 - _r5 * _s0 + _r6 * _s3
					sample[_b7] = _r3 * _s7 - _r0 * _s4 - _r1 * _s5 - _r2 * _s6 - _r4 * _s0 - _r5 * _s1 - _r6 * _s2
				}
		
				if i <= 0 {
					break
				}
		
				b = _descendants[--i]
			}
		}
		
		update_sample = undefined
		
		static tick = function () {
			if animation != undefined {
				var _animation_type = animation.type
				var _frame_step = frame_speed * animation.frame_speed
				
				animation_finished = false
				
				if _animation_type == AnimationTypes.LINEAR_LOOP or _animation_type == AnimationTypes.QUADRATIC_LOOP {
					// Looping animation
					frame += _frame_step
				} else {
					// Animation plays only once
					var _frames = animation.frames - 1
					
					frame = clamp(frame + _frame_step, 0, _frames)
					animation_finished = frame >= _frames
				}
				
				if transition < transition_time {
					++transition
				}
			}
		}
	#endregion
	
	#region Transform
		matrix = matrix_build(_x, _y, _z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale)
		
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
		
		static draw = function () {
			var _mwp = matrix_get(matrix_world)
			
			matrix = matrix_build(sx, sy, sz, sroll, spitch, syaw, sscale * sx_scale, sscale * sy_scale, sscale * sz_scale)
			matrix_set(matrix_world, matrix)
			
			global.u_color.set(color_get_red(color) * COLOR_INVERSE, color_get_green(color) * COLOR_INVERSE, color_get_blue(color) * COLOR_INVERSE, alpha)
			
			if animation == undefined {
				global.u_animated.set(0)
			} else {
				global.u_animated.set(1)
				
				var _frame = sframe
				var _frames, _loop, _real_frame, _samples
				
				with animation {
					_frames = frames
					_loop = type == AnimationTypes.LINEAR_LOOP or type == AnimationTypes.QUADRATIC_LOOP
					_real_frame = _loop ? _frame mod frames : min(_frame, frames)
					_samples = samples
				}
				
				var _next_frame = -~_real_frame
				var _final_sample = sample
				
				sample_blend(_final_sample, _samples[floor(_real_frame)], _samples[floor(_loop ? _next_frame % _frames : min(_next_frame, _frames))], frac(_real_frame))
				
				if update_sample != undefined {
					update_sample.setSelf(self)
					update_sample()
				}
				
				if stransition < transition_time {
					sample_blend(transition_sample2, transition_sample, sample, stransition / transition_time)
					_final_sample = transition_sample2
				}
				
				global.u_bone_dq.set(_final_sample)
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
			var i = 0
			
			repeat submodels_amount {
				var _skin = skins[i]
				
				if _skin == -1 {
					++i
					
					continue
				}
				
				with submodels[i] {
					var _material = materials[_skin]
					var _image
					
					with _material {
						_image = image
						
						if image2 != undefined {
							_u_material_can_blend.set(1)
							
							if image2 == -1 {
								_u_material_blend.set(-1)
							} else {
								_u_material_blend.set(image2.GetTexture(0))
							
								var _uvs = _image.GetUVs(_idx)
							
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
					
					if _image == -1 {
						vertex_submit(vbo, pr_trianglelist, -1)
					} else {
						var _idx
						
						with _material {
							_idx = frame_speed * current_time
							_u_material_alpha_test.set(alpha_test)
							_u_material_scroll.set(x_scroll, y_scroll)
						}
						
						var _uvs = _image.GetUVs(_idx)
						
						with _uvs {
							_u_uvs.set(normLeft, normTop, normRight, normBottom)
						}
						
						vertex_submit(vbo, pr_trianglelist, _image.GetTexture(_idx))
					}
				}
				
				++i
			}
			
			matrix_set(matrix_world, _mwp)
		}
	#endregion
}