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
	
	#region Animation
		animated = false
		animation_name = ""
		animation = undefined
		animation_finished = false
		animation_state = 0
		animation_bind_pose_id = ""
		animation_bind_pose = undefined
		animation_samples = undefined
		frame = 0
		frame_speed = 1
		
		transition = 0
		transition_time = 0
		transition_sample = dq_build_identity()
		tick_sample = dq_build_identity()
		from_sample = dq_build_identity()
		draw_sample = dq_build_identity()
		
		splice_name = ""
		splice = undefined
		splice_bone = -1
		splice_frame = 0
		splice_push = false
		
		static set_animation = function (_animation = undefined, _frame = 0, _time = 0) {
			if _animation == undefined {
				animation_name = ""
				animation = undefined
				animation_finished = false
				animation_state = 0
				
				if _frame >= 0 {
					frame = _frame
					frame_speed = 1
				}
				
				transition = 0
				transition_time = 0
				
				exit
			}
			
			animation_name = _animation.name
			animation = _animation
			animation_finished = false
			animation_state = 0
			
			var _bind_poses = _animation.bind_poses
			var _bpid = animation_bind_pose_id
			
			if not ds_map_exists(_bind_poses, _bpid) {
				print($"! ModelInstance: Bind pose '{_bpid}' not found")
				_bpid = ""
			}
			
			animation_bind_pose = _bind_poses[? _bpid]
			animation_samples = _animation.samples[? _bpid]
			
			var _first = not animated
			var _copy = _first
			
			if _frame >= 0 {
				_copy = true
				frame = _frame
				frame_speed = 1
			}
			
			transition = 0
			transition_time = _time
			
			if _time > 0 {
				array_copy(transition_sample, 0, tick_sample, 0, array_length(tick_sample))
			}
			
			if _copy {
				var _frame1 = floor(_frame)
				var _frame2 = -~_frame1
				var _type, _frames
				
				with _animation {
					_type = type
					_frames = frames
				}
				
				if _type % 2 {
					_frame1 = _frame1 % _frames
					_frame2 = _frame2 % _frames
				} else {
					_frame1 = min(_frame1, _frames)
					_frame2 = min(_frame2, _frames)
				}
				
				var _copy_sample1 = animation_samples[_frame1]
				var _copy_sample2 = animation_samples[_frame2]
				
				sample_blend(tick_sample, _copy_sample1, _copy_sample2, frac(_frame))
				
				if _first {
					animated = true
				} else {
					if splice != undefined {
						splice_animation(splice, splice_frame, splice_bone)
					}
					
					if update_sample != undefined {
						update_sample(self)
					}
				}
				
				var n = array_length(tick_sample)
				
				array_copy(from_sample, 0, tick_sample, 0, n)
				array_copy(draw_sample, 0, tick_sample, 0, n)
			}
		}
		
		static set_splice_animation = function (_animation = undefined, _bone = 0, _frame = 0, _push = false) {
			if _frame < 0 and _animation != undefined {
				_frame = _animation.frames
			}
			
			splice_name = _animation == undefined ? "" : _animation.name
			splice = _animation
			splice_finished = false
			splice_bone = _bone
			splice_frame = _frame
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
			
			var _sample = _visual ? draw_sample : tick_sample
			var b = 8 * _index
			var s = animation_bind_pose[_index]
			var r3 = _sample[b + 3]
			var r4 = _sample[b + 4]
			var r5 = _sample[b + 5]
			var r6 = _sample[b + 6]
			
			if r3 == 1 and r4 == 0 and r5 == 0 and r6 == 0 {
				// An early out if this bone has not been transformed, letting
				// us skip a dual quaternion multiplication
				array_copy(bone_dq, 0, s, 0, 8)
		
				return bone_dq
			}
			
			var r0 = _sample[b]
			var r1 = _sample[-~b]
			var r2 = _sample[b + 2]
			var r7 = _sample[b + 7]
			
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
			var _bone = animation_bind_pose[_index]
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
					
					var _s0 = tick_sample[b]
					var _s1 = tick_sample[_b1]
					var _s2 = tick_sample[_b2]
					var _s3 = tick_sample[_b3]
					var _s4 = tick_sample[_b4]
					var _s5 = tick_sample[_b5]
					var _s6 = tick_sample[_b6]
					var _s7 = tick_sample[_b7]
					
					tick_sample[b] = _r3 * _s0 + _r0 * _s3 + _r1 * _s2 - _r2 * _s1
					tick_sample[_b1] = _r3 * _s1 - _r0 * _s2 + _r1 * _s3 + _r2 * _s0
					tick_sample[_b2] = _r3 * _s2 + _r0 * _s1 - _r1 * _s0 + _r2 * _s3
					tick_sample[_b3] = _r3 * _s3 - _r0 * _s0 - _r1 * _s1 - _r2 * _s2
					tick_sample[_b4] = _r3 * _s4 + _r0 * _s7 + _r1 * _s6 - _r2 * _s5 + _r4 * _s3 + _r5 * _s2 - _r6 * _s1
					tick_sample[_b5] = _r3 * _s5 - _r0 * _s6 + _r1 * _s7 + _r2 * _s4 - _r4 * _s2 + _r5 * _s3 + _r6 * _s0
					tick_sample[_b6] = _r3 * _s6 + _r0 * _s5 - _r1 * _s4 + _r2 * _s7 + _r4 * _s1 - _r5 * _s0 + _r6 * _s3
					tick_sample[_b7] = _r3 * _s7 - _r0 * _s4 - _r1 * _s5 - _r2 * _s6 - _r4 * _s0 - _r5 * _s1 - _r6 * _s2
				}
				
				if i <= 0 {
					break
				}
				
				b = _descendants[--i]
			}
		}
		
		static splice_animation = function (_animation, _frame, _bone_index, _weight = 1) {
			static splice_sample = []
			
			if _animation == undefined {
				exit
			}
			
			var _current_sample, _next_sample, n, _samples, _bind_pose
			var _bpid = animation_bind_pose_id
			
			with _animation {
				var n = frames
				
				if type % 2 {
					_current_sample = floor(_frame) % n
					_next_sample = floor(_frame + 1) % n
				} else {
					_current_sample = min(floor(_frame), n)
					_next_sample = min(floor(_frame + 1), n)
				}
				
				if not ds_map_exists(bind_poses, _bpid) {
					_bpid = ""
				}
				
				_samples = samples[? _bpid]
				_bind_pose = bind_poses[? _bpid]
			}
			
			sample_blend(splice_sample, _samples[_current_sample], _samples[_next_sample], frac(_frame))
			
			var _bone = _bind_pose[_bone_index]
			var _parent_index = _bone[8]
			var _parent = _bind_pose[_parent_index]
			
			// Find the change in orientation from the source sample to the
			// destination sample. Same as dq_multiply(D, dq_get_conjugate(S))
			var b = _parent_index * 8
			var b1 = -~b
			var b2 = b + 2
			var b3 = b + 3
			var b4 = b + 4
			var b5 = b + 5
			var b6 = b + 6
			var b7 = b + 7
			
			var s0 = splice_sample[b]
			var s1 = splice_sample[b1]
			var s2 = splice_sample[b2]
			var s3 = splice_sample[b3]
			var s4 = splice_sample[b4]
			var s5 = splice_sample[b5]
			var s6 = splice_sample[b6]
			var s7 = splice_sample[b7]
			
			var d0 = tick_sample[b]
			var d1 = tick_sample[b1]
			var d2 = tick_sample[b2]
			var d3 = tick_sample[b3]
			var d4 = tick_sample[b4]
			var d5 = tick_sample[b5]
			var d6 = tick_sample[b6]
			var d7 = tick_sample[b7]
			
			var r0 = -d3 * s0 + d0 * s3 - d1 * s2 + d2 * s1
			var r1 = -d3 * s1 + d1 * s3 - d2 * s0 + d0 * s2
			var r2 = -d3 * s2 + d2 * s3 - d0 * s1 + d1 * s0
			var r3 =  d3 * s3 + d0 * s0 + d1 * s1 + d2 * s2
			var r4 = -d3 * s4 + d0 * s7 - d1 * s6 + d2 * s5 - d7 * s0 + d4 * s3 - d5 * s2 + d6 * s1
			var r5 = -d3 * s5 + d1 * s7 - d2 * s4 + d0 * s6 - d7 * s1 + d5 * s3 - d6 * s0 + d4 * s2
			var r6 = -d3 * s6 + d2 * s7 - d0 * s5 + d1 * s4 - d7 * s2 + d6 * s3 - d4 * s1 + d5 * s0
			var r7 =  d3 * s7 + d0 * s4 + d1 * s5 + d2 * s6 + d7 * s3 + d4 * s0 + d5 * s1 + d6 * s2
			
			/* Transform the source sample so that it stays attached to the
			   parent in the destination sample. Linearly interpolate between
			   source and destination samples. */
			var _descendants = _bone[10]
			var i = 0
			
			n = array_length(_descendants)
			b = _bone_index * 8
			
			repeat -~n {
				if b >= 0 {
					b1 = -~b
					b2 = b + 2
					b3 = b + 3
					b4 = b + 4
					b5 = b + 5
					b6 = b + 6
					b7 = b + 7
					
					s0 = splice_sample[b]
					s1 = splice_sample[b1]
					s2 = splice_sample[b2]
					s3 = splice_sample[b3]
					s4 = splice_sample[b4]
					s5 = splice_sample[b5]
					s6 = splice_sample[b6]
					s7 = splice_sample[b7]
					
					var d0 = tick_sample[b]
					var d1 = tick_sample[b1]
					var d2 = tick_sample[b2]
					var d3 = tick_sample[b3]
					var d4 = tick_sample[b4]
					var d5 = tick_sample[b5]
					var d6 = tick_sample[b6]
					var d7 = tick_sample[b7]
					
					tick_sample[b] += _weight * (r3 * s0 + r0 * s3 + r1 * s2 - r2 * s1 - d0)
					tick_sample[b1] += _weight * (r3 * s1 + r1 * s3 + r2 * s0 - r0 * s2 - d1)
					tick_sample[b2] += _weight * (r3 * s2 + r2 * s3 + r0 * s1 - r1 * s0 - d2)
					tick_sample[b3] += _weight * (r3 * s3 - r0 * s0 - r1 * s1 - r2 * s2 - d3)
					tick_sample[b4] += _weight * (r3 * s4 + r0 * s7 + r1 * s6 - r2 * s5 + r7 * s0 + r4 * s3 + r5 * s2 - r6 * s1 - d4)
					tick_sample[b5] += _weight * (r3 * s5 + r1 * s7 + r2 * s4 - r0 * s6 + r7 * s1 + r5 * s3 + r6 * s0 - r4 * s2 - d5)
					tick_sample[b6] += _weight * (r3 * s6 + r2 * s7 + r0 * s5 - r1 * s4 + r7 * s2 + r6 * s3 + r4 * s1 - r5 * s0 - d6)
					tick_sample[b7] += _weight * (r3 * s7 - r0 * s4 - r1 * s5 - r2 * s6 + r7 * s2 - r4 * s0 - r5 * s1 - r6 * s2 - d7)
				}
				
				if i < n {
					b = _descendants[i] * 8
				}
				
				++i
			}
		}
		
		update_sample = undefined
		
		static tick = function (_update_matrix = true) {
			var _update_sample = false
			
			if animation != undefined {
				var _animation_type = animation.type
				var _frame_step = frame_speed * animation.frame_speed
				
				animation_finished = false
				
				if _animation_type % 2 {
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
				
				_update_sample = true
			}
			
			if splice != undefined {
				splice_frame += splice.frame_speed
				splice_finished = false
				
				if not (splice.type % 2) and splice_frame >= splice.frames {
					splice_finished = true
					
					if splice_push {
						splice = undefined
					}
				} else {
					_update_sample = true
				}
			}
			
			if _update_sample {
				var _frame = frame
				var _frames, _loop, _current_frame, _next_frame
				
				with animation {
					_frames = frames
					_loop = type % 2
					
					if _loop {
						_current_frame = _frame mod _frames
						_next_frame = (_frame + 1) mod _frames
					} else {
						_current_frame = min(_frame, _frames)
						_next_frame = min(_frame + 1, _frames)
					}
				}
				
				var _current_sample = animation_samples[floor(_current_frame)]
				var _next_sample = animation_samples[floor(_next_frame)]
				
				array_copy(from_sample, 0, tick_sample, 0, array_length(tick_sample))
				sample_blend(tick_sample, _current_sample, _next_sample, frac(_current_frame))
				
				if splice != undefined {
					splice_animation(splice, splice_frame, splice_bone)
				}
				
				if update_sample != undefined {
					update_sample(self)
				}
				
				if transition < transition_time {
					sample_blend(tick_sample, transition_sample, tick_sample, transition / transition_time)
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
			
			if animation == undefined {
				global.u_animated.set(0)
			} else {
				global.u_animated.set(1)
				sample_blend(draw_sample, from_sample, tick_sample, global.tick)
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
				
				repeat submodels_amount {
					var _skin = skins[i]
					
					if _skin == -1 {
						++i
						
						continue
					}
					
					var _submodel = submodels[i++]
					
					cache[j] = _submodel.vbo
					cache[-~j] = _submodel.materials[_skin]
					j += 2;
					++k
				}
				
				array_resize(cache, j)
				cache_amount = k
				skins_updated = false
			}
			
			var i = 0
			
			repeat cache_amount {
				var _material = cache[-~i]
				var _image
				
				with _material {
					_image = image
					
					if image2 != undefined {
						_u_material_can_blend.set(1)
						
						if image2 == -1 {
							_u_material_blend.set(-1)
						} else {
							_u_material_blend.set(image2.GetTexture(0))
							
							var _uvs = image2.GetUVs(0)
							
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
				
				var _vbo = cache[i]
				
				if _image == -1 {
					vertex_submit(_vbo, pr_trianglelist, -1)
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
					
					vertex_submit(_vbo, pr_trianglelist, _image.GetTexture(_idx))
				}
				
				i += 2
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