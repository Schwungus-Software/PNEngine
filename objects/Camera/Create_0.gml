#macro SKY_SCROLL_FACTOR -0.3515625

enum CameraTargetData {
	RANGE,
	X_OFFSET,
	Y_OFFSET,
	Z_OFFSET,
}

enum CameraPOIData {
	LERP,
	X_OFFSET,
	Y_OFFSET,
	Z_OFFSET,
}

enum CameraPathData {
	TIME,
	X,
	Y,
	Z,
	YAW,
	PITCH,
	ROLL,
	FOV,
	__SIZE,
}

event_inherited()

#region Variables
	f_sync_vel = false
	
	yaw = 0
	roll = 0
	fov = 45
	
	interp("yaw", "syaw", true)
	interp("pitch", "spitch", true)
	interp("roll", "sroll", true)
	interp("fov", "sfov")
	
	range = 0
	targets = ds_map_create()
	pois = ds_map_create()
	child = noone
	parent = noone
	f_raycast = true
	
	view_matrix = undefined
	projection_matrix = undefined
	
	path = ds_grid_create(0, CameraPathData.__SIZE)
	path_elapsed = 0
	path_time = 0
	path_playback = AnimationTypes.LINEAR
	path_active = false
	
	quake = 0
	quake_x = 0
	quake_y = 0
	quake_z = 0
	
	interp("quake_x", "squake_x")
	interp("quake_y", "squake_y")
	interp("quake_z", "squake_z")
	
	alpha = 1
	output = (new Canvas(480, 270)).SetDepthDisabled(true)
#endregion

#region Functions
	resolve = function () {
		if instance_exists(parent) {
			return parent.resolve()
		}
		
		return id
	}
	
	add_target = function (_target, _range = 100, _x_offset = 0, _y_offset = 0, _z_offset = 0) {
		ds_map_add(targets, _target, [_range, _x_offset, _y_offset, _z_offset])
	}
	
	delete_target = function (_target) {
		if _target == all {
			ds_map_clear(targets)
		} else {
			ds_map_delete(targets, _target)
		}
	}
	
	add_poi = function (_target, _lerp = 1, _x_offset = 0, _y_offset = 0, _z_offset = 0) {
		ds_map_add(pois, _target, [_lerp, _x_offset, _y_offset, _z_offset])
	}
	
	delete_poi = function (_target) {
		if _target == all {
			ds_map_clear(pois)
		} else {
			ds_map_delete(pois, _target)
		}
	}
	
	add_path = function (_time, _x, _y, _z, _yaw, _pitch, _roll, _fov) {
		gml_pragma("forceinline")
		
		var i = ds_grid_width(path)
		
		ds_grid_resize(path, -~i, CameraPathData.__SIZE)
		path[# i, CameraPathData.TIME] = _time
		path[# i, CameraPathData.X] = _x
		path[# i, CameraPathData.Y] = _y
		path[# i, CameraPathData.Z] = _z
		path[# i, CameraPathData.YAW] = _yaw
		path[# i, CameraPathData.PITCH] = _pitch
		path[# i, CameraPathData.ROLL] = _roll
		path[# i, CameraPathData.FOV] = _fov
	}
	
	clear_path = function () {
		ds_grid_resize(path, 0, CameraPathData.__SIZE)
		stop_path()
	}
	
	start_path = function (_time, _playback) {
		if ds_grid_width(path) == 0 {
			return false
		}
		
		path_elapsed = 0
		path_time = _time
		path_playback = _playback
		path_active = true
		
		x = path[# 0, CameraPathData.X]
		y = path[# 0, CameraPathData.Y]
		z = path[# 0, CameraPathData.Z]
		yaw = path[# 0, CameraPathData.YAW]
		pitch = path[# 0, CameraPathData.PITCH]
		roll = path[# 0, CameraPathData.ROLL]
		fov = path[# 0, CameraPathData.FOV]
		interp_skip("sx")
		interp_skip("sy")
		interp_skip("sz")
		interp_skip("syaw")
		interp_skip("spitch")
		interp_skip("sroll")
		interp_skip("sfov")
		
		return true
	}
	
	stop_path = function () {
		path_active = false
	}
	
	set_child = function (_camera) {
		if instance_exists(child) {
			child.parent = noone
		}
	
		child = _camera
		
		if instance_exists(_camera) {
			_camera.parent = id
		}
	}
	
	update_matrices = function (_width = window_get_width(), _height = window_get_height(), _update_listener = false) {
		var _nx = dcos(syaw)
		var _ny = -dsin(syaw)
		var _nz = dtan(clamp(spitch, -89.95, 89.95))
		var _yup = dsin(sroll)
		var _zup = dcos(sroll)
		
		view_matrix = matrix_build_lookat(sx, sy, sz, sx + _nx, sy + _ny, sz + _nz, 0, _yup, _zup)
		projection_matrix = matrix_build_projection_perspective_fov(-sfov, -(_width / _height), 1, 65535)
		
		if _update_listener {
			audio_listener_position(sx, sy, sz)
			audio_listener_orientation(-_nx, -_ny, _nz, 0, _yup, _zup)
		}
	}
	
	world_to_screen = function (_x, _y, _z) {
		static _pos = []
		
		var _w = view_matrix[2] * _x + view_matrix[6] * _y + view_matrix[10] * _z + view_matrix[14]
		
		if _w <= 0 {
			return undefined
		}
		
		var _w_inv = 1 / _w
		var _cx = projection_matrix[8] + projection_matrix[0] * (view_matrix[0] * _x + view_matrix[4] * _y + view_matrix[8] * _z + view_matrix[12]) * _w_inv
		var _cy = projection_matrix[9] + projection_matrix[5] * (view_matrix[1] * _x + view_matrix[5] * _y + view_matrix[9] * _z + view_matrix[13]) * _w_inv
		
		_pos[0] = 0.5 + 0.5 * _cx
		_pos[1] = 0.5 + 0.5 * _cy
		
		return _pos
	}
	
	render = function (_width, _height, _update_listener = false, _allow_sky = true, _allow_screen = true, _world_shader = global.world_shader) {
		if instance_exists(child) {
			return child.render(_width, _height, _update_listener, _allow_sky, _allow_screen, _world_shader)
		}
		
		output.Resize(_width, _height)
		sx += squake_x
		sy += squake_y
		sz += squake_z
		
		var _area = area
		
		//if _area != undefined {
			output.Start()
			
			var _canvases = global.canvases
			var _render_canvas = _canvases[Canvases.RENDER]
			
			with _render_canvas {
				Resize(_width, _height)
				Start()
			}
			
			var _world_canvas = _canvases[Canvases.WORLD]
			
			with _world_canvas {
				Resize(_width, _height)
				Clear(c_black)
				Start()
			}
			
			var _render_camera = view_camera[0]
			
			update_matrices(_width, _height, _update_listener)
			
			var _view_matrix = view_matrix
			var _projection_matrix = projection_matrix
			
			camera_set_view_mat(_render_camera, _view_matrix)
			camera_set_proj_mat(_render_camera, _projection_matrix)
			camera_apply(_render_camera)
			
			var _ambient_color, _fog_distance, _fog_color, _wind_strength, _wind_direction, _light_data
			
			with _area {
				_ambient_color = ambient_color
				_fog_distance = fog_distance
				_fog_color = fog_color
				_wind_strength = wind_strength
				_wind_direction = wind_direction
				_light_data = light_data
			}
			
			var _time = current_time
			var _gpu_tex_filter = gpu_get_tex_filter()
			var _config = global.config
			var _vid_texture_filter = _config.vid_texture_filter
			
			gpu_set_tex_filter(_vid_texture_filter)
			global.batch_camera = id
			
			var _active_things
			var _x = sx
			var _y = sy
			var _z = sz
			
			with _area {
				if _allow_sky {
					if instance_exists(sky) and sky.model != undefined {
						gpu_set_blendenable(false)
						gpu_set_zwriteenable(false)
						global.sky_shader.set()
					
						with sky {
							with model {
								sx = _x
								sy = _y
								sz = _z
							
								var _material = other.material
								var _scroll = _time * SKY_SCROLL_FACTOR
							
								syaw = _scroll * _material.x_scroll
								spitch = _scroll * _material.y_scroll
							}
						
							event_user(ThingEvents.DRAW)
						}
					
						shader_reset()
						gpu_set_zwriteenable(true)
						gpu_set_blendenable(true)
					} else {
						_world_canvas.Clear(clear_color[4])
					}
				} else {
					_world_canvas.Clear()
				}
				
				_world_shader.set()
				global.u_ambient_color.set(_ambient_color[0], _ambient_color[1], _ambient_color[2], _ambient_color[3])
				global.u_fog_distance.set(_fog_distance[0], _fog_distance[1])
				global.u_fog_color.set(_fog_color[0], _fog_color[1], _fog_color[2], _fog_color[3])
				global.u_wind.set(_wind_strength, _wind_direction[0], _wind_direction[1], _wind_direction[2])
				global.u_light_data.set(_light_data)
				global.u_time.set(_time * 0.001)
				
				if model != undefined {
					model.draw()
				}
				
				_active_things = active_things
				
				var i = ds_list_size(_active_things)
				
				repeat i {
					with _active_things[| --i] {
						if f_visible and point_distance(_x, _y, sx, sy) < cull_draw {
							event_user(ThingEvents.DRAW)
						}
					}
				}
				
				i = 0
				
				repeat ds_list_size(particles) {
					var p = particles[| i++]
					
					batch_set_alpha_test(p[ParticleData.ALPHA_TEST])
					batch_set_bright(p[ParticleData.BRIGHT])
					batch_billboard(p[ParticleData.IMAGE], p[ParticleData.FRAME], p[ParticleData.WIDTH], p[ParticleData.HEIGHT], p[ParticleData.X], p[ParticleData.Y], p[ParticleData.Z], p[ParticleData.ANGLE], p[ParticleData.COLOR], p[ParticleData.ALPHA])
				}
				
				batch_submit()
				gpu_set_tex_filter(_gpu_tex_filter)
				shader_reset()
				_world_canvas.Finish()
			}
			
			if not _allow_screen or alpha >= 1 {
				gpu_set_blendenable(false)
				_world_canvas.Draw(0, 0)
				gpu_set_blendenable(true)
			} else {
				// Do some weird stuff with blendmodes to ensure that the
				// motion blur displays correctly both with and without bloom.
				gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one)
				_world_canvas.DrawExt(0, 0, 1, 1, 0, c_white, clamp(global.delta * alpha, 0, 1))
				gpu_set_blendmode(bm_normal)
			}
			
			with _render_canvas {
				Finish()
				gpu_set_blendenable(false)
				Draw(0, 0)
				gpu_set_blendenable(true)
			}
			
			output.Finish()
			
			if _allow_screen {
				output.Start()
				
				// Bloom
				if _config.vid_bloom {
					var _bloom_canvas = _canvases[Canvases.BLOOM]
					
					gpu_set_blendenable(false)
					global.bloom_pass_shader.set()
					global.u_threshold.set(0.885)
					global.u_intensity.set(0.09)
					
					var _half_width = _width * 0.25
					var _half_height = _height * 0.25
					
					with _bloom_canvas {
						Resize(_half_width, _half_height)
						Start()
					}
					
					gpu_set_tex_repeat(false)
					gpu_set_tex_filter(true)
					_render_canvas.DrawStretched(0, 0, _half_width, _half_height)
					_bloom_canvas.Finish()
					shader_reset()
					gpu_set_blendenable(true)
					gpu_set_blendmode(bm_add)
					global.bloom_shader.set()
					global.u_resolution.set(_half_width, _half_height)
					_bloom_canvas.DrawStretched(0, 0, _width, _height)
					shader_reset()
					gpu_set_tex_filter(false)
					gpu_set_tex_repeat(true)
					gpu_set_blendmode(bm_normal)
				}
				
				// HUD
				var  _self = id
				var i = ds_list_size(_active_things)
				
				repeat i {
					with _active_things[| --i] {
						if f_visible {
							screen_camera = _self
							screen_width = _width
							screen_height = _height
							gpu_set_depth(screen_depth)
							event_user(ThingEvents.DRAW_SCREEN)
						}
					}
				}
				
				gpu_set_depth(0)
				output.Finish()
			}
		//}
		
		return output
	}
#endregion