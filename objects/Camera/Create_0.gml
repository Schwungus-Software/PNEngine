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
	//f_sync_vel = false
	
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
	
	forward_axis = matrix_build(1, 0, 0, 0, 0, 0, 1, 1, 1)
	up_axis = matrix_build(0, 0, -1, 0, 0, 0, 1, 1, 1)
	view_matrix = undefined
	projection_matrix = undefined
	f_ortho = false
	
	path = ds_grid_create(0, CameraPathData.__SIZE)
	path_elapsed = 0
	path_time = 0
	path_quadratic = false
	path_loop = false
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
	
	listener_pos = new FmodVector()
	listener_vel = new FmodVector()
	listener_rot = new FmodVector()
	listener_up = new FmodVector()
	
	with listener_up {
		x = 0
		y = 0
		z = 1
	}
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
	
	start_path = function (_time, _quadratic = false, _loop = false) {
		if ds_grid_width(path) == 0 {
			return false
		}
		
		path_elapsed = 0
		path_time = _time
		path_quadratic = _quadratic
		path_loop = _loop
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
	
	set_active = function (_bool) {
		if _bool {
			global.camera_active = id
			
			return true
		} else {
			if global.camera_active == id {
				global.camera_active = noone
				
				return true
			}
		}
		
		return false
	}
	
	update_matrices = function (_width = window_get_width(), _height = window_get_height(), _update_listener = false) {
		var _matrix = matrix_build(0, 0, 0, sroll, spitch, syaw, 1, 1, 1)
		
		var _forward = matrix_multiply(forward_axis, _matrix)
		var _fx = _forward[12]
		var _fy = _forward[13]
		var _fz = _forward[14]
		
		var _up = matrix_multiply(up_axis, _matrix)
		var _ux = _up[12]
		var _uy = _up[13]
		var _uz = _up[14]
		
		view_matrix = matrix_build_lookat(sx, sy, sz, sx + _fx, sy + _fy, sz + _fz, _ux, _uy, _uz)
		projection_matrix = f_ortho ? matrix_build_projection_ortho(_width * 0.5, -_height * 0.5, 1, 65535) : matrix_build_projection_perspective_fov(-sfov, -(_width / _height), 1, 65535)
		
		if _update_listener {
			listener_pos.x = sx
			listener_pos.y = sy
			listener_pos.z = sz
			
			with listener_rot {
				x = _fx
				y = _fy
				z = _fz
			}
			
			with listener_up {
				x = _ux
				y = _uy
				z = _uz
			}
			
			// TODO: Implement multiple listeners for splitscreen
			fmod_system_set_3d_listener_attributes(0, listener_pos, listener_vel, listener_rot, listener_up)
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
	
	render = function (_width, _height, _update_listener = false, _allow_sky = true, _allow_screen = true, _world_shader = global.config.vid_lighting ? global.world_pixel_shader : global.world_shader) {
		++global.camera_layer
		
		if global.camera_layer == 1 {
			gpu_set_cullmode(cull_counterclockwise)
		}
		
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
				Start()
			}
			
			var _render_camera = view_camera[0]
			
			update_matrices(_width, _height, _update_listener)
			
			var _view_matrix = view_matrix
			var _projection_matrix = projection_matrix
			
			camera_set_view_mat(_render_camera, _view_matrix)
			camera_set_proj_mat(_render_camera, _projection_matrix)
			camera_apply(_render_camera)
			
			var _time = current_time * 0.001
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
					draw_clear(clear_color[4])
					
					if instance_exists(sky) and sky.model != undefined {
						gpu_set_zwriteenable(false)
						global.sky_shader.set()
						global.u_time.set(_time)
					
						with sky {
							with model {
								sx = _x
								sy = _y
								sz = _z
							}
							
							event_user(ThingEvents.DRAW)
						}
					
						shader_reset()
						gpu_set_zwriteenable(true)
					}
				} else {
					draw_clear(c_black)
				}
				
				_world_shader.set()
				global.u_ambient_color.set(ambient_color[0], ambient_color[1], ambient_color[2], ambient_color[3])
				global.u_fog_distance.set(fog_distance[0], fog_distance[1])
				global.u_fog_color.set(fog_color[0], fog_color[1], fog_color[2], fog_color[3])
				global.u_wind.set(wind_strength, wind_direction[0], wind_direction[1], wind_direction[2])
				global.u_light_data.set(light_data)
				global.u_time.set(_time)
				
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
					batch_set_blendmode(p[ParticleData.BLENDMODE])
					batch_billboard(p[ParticleData.IMAGE], p[ParticleData.FRAME], p[ParticleData.WIDTH], p[ParticleData.HEIGHT], p[ParticleData.X], p[ParticleData.Y], p[ParticleData.Z], p[ParticleData.ANGLE], p[ParticleData.COLOR], p[ParticleData.ALPHA])
				}
				
				batch_submit()
				gpu_set_tex_filter(_gpu_tex_filter)
				shader_reset()
				_world_canvas.Finish()
			}
			
			gpu_set_blendenable(false)
			_world_canvas.Draw(0, 0)
			gpu_set_blendenable(true)
			_render_canvas.Finish()
			
			if not _allow_screen or alpha >= 1 {
				gpu_set_blendenable(false)
				_render_canvas.Draw(0, 0)
				gpu_set_blendenable(true)
			} else {
				_render_canvas.DrawExt(0, 0, 1, 1, 0, c_white, clamp(global.delta * alpha, 0, 1))
			}
			
			output.Finish();
			--global.camera_layer
			
			if global.camera_layer == 0 {
				gpu_set_cullmode(cull_noculling)
			}
			
			if _allow_screen {
				output.Start()
				
				// Bloom
				if _config.vid_bloom {
					gpu_set_blendenable(false)
					global.bloom_pass_shader.set()
					global.u_threshold.set(0.85)
					global.u_intensity.set(0.36)
					
					var _bloom = global.bloom
					var _third_width = _width div 3
					var _third_height = _height div 3
					
					_bloom.resize(_third_width, _third_height)
					
					var _surface = _bloom.get_surface()
					
					surface_set_target(_surface)
					gpu_set_tex_repeat(false)
					gpu_set_tex_filter(true)
					_render_canvas.DrawStretched(0, 0, _third_width, _third_height)
					surface_reset_target()
					shader_reset()
					_bloom.blur()
					gpu_set_blendenable(true)
					gpu_set_blendmode(bm_add)
					draw_surface_stretched(_surface, 0, 0, _width, _height)
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