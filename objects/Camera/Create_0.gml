enum CameraTargetData {
	RANGE,
	X_OFFSET,
	Y_OFFSET,
	Z_OFFSET,
}

enum CameraPOIData {
	SMOOTH,
	X_OFFSET,
	Y_OFFSET,
	Z_OFFSET,
}

event_inherited()

#region Variables
	yaw = 0
	pitch = 0
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
	
	view_matrix = undefined
	projection_matrix = undefined
	
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
	
	add_poi = function (_target, _smooth = false, _x_offset = 0, _y_offset = 0, _z_offset = 0) {
		ds_map_add(pois, _target, [_smooth, _x_offset, _y_offset, _z_offset])
	}
	
	delete_poi = function (_target) {
		if _target == all {
			ds_map_clear(pois)
		} else {
			ds_map_delete(pois, _target)
		}
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
	
	update_matrices = function (_width = window_get_width(), _height = window_get_height()) {
		var _nx = dcos(syaw)
		var _ny = -dsin(syaw)
		var _nz = dtan(clamp(spitch, -89.95, 89.95))
		var _yup = dsin(sroll)
		var _zup = dcos(sroll)
		
		view_matrix = matrix_build_lookat(sx, sy, sz, sx + _nx, sy + _ny, sz + _nz, 0, _yup, _zup)
		projection_matrix = matrix_build_projection_perspective_fov(-sfov, -(_width / _height), 1, 65535)
		audio_listener_position(sx, sy, sz)
		audio_listener_orientation(-_nx, -_ny, _nz, 0, _yup, _zup)
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
	
	render = function (_width, _height, _allow_screen = true, _world_shader = global.world_shader) {
		if instance_exists(child) {
			return child.render(_width, _height, _allow_screen)
		}
		
		output.Resize(_width, _height)
		
		var _area = area
		
		if _area != undefined {
			var _active_things = _area.active_things
			
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
				Clear(c_black, 0)
				Start()
			}
			
			var _render_camera = view_camera[0]
			
			update_matrices(_width, _height)
			
			var _view_matrix = view_matrix
			var _projection_matrix = projection_matrix
			
			camera_set_view_mat(_render_camera, _view_matrix)
			camera_set_proj_mat(_render_camera, _projection_matrix)
			camera_apply(_render_camera)
			
			var _ambient_color, _fog_distance, _fog_color
			
			with _area {
				_ambient_color = ambient_color
				_fog_distance = fog_distance
				_fog_color = fog_color
			}
			
			with _world_shader {
				set()
				set_uniform("u_ambient_color", _ambient_color[0], _ambient_color[1], _ambient_color[2], _ambient_color[3])
				set_uniform("u_fog_distance", _fog_distance[0], _fog_distance[1])
				set_uniform("u_fog_color", _fog_color[0], _fog_color[1], _fog_color[2], _fog_color[3])
				set_uniform("u_light_data", _area.light_data)
			}
			
			var _gpu_tex_filter = gpu_get_tex_filter()
			var _vid_texture_filter = global.config.vid_texture_filter
			
			gpu_set_tex_filter(_vid_texture_filter)
			global.batch_camera = id
			
			var _x = sx
			var _y = sy
			var _z = sz
			var i = ds_list_size(_active_things)
			
			repeat i {
				with _active_things[| --i] {
					if f_visible and (cull_draw == -1 or point_distance(_x, _y, sx, sy) < cull_draw) {
						event_user(ThingEvents.DRAW)
					}
				}
			}
			
			with _area {
				if model != undefined {
					model.draw()
				}
				
				var i = 0
				
				repeat ds_list_size(particles) {
					var p = particles[| i++]
					
					batch_set_bright(p[ParticleData.BRIGHT])
					batch_billboard(p[ParticleData.IMAGE], p[ParticleData.FRAME], p[ParticleData.WIDTH], p[ParticleData.HEIGHT], p[ParticleData.X], p[ParticleData.Y], p[ParticleData.Z], p[ParticleData.ANGLE], p[ParticleData.COLOR], p[ParticleData.ALPHA])
				}
				
				batch_submit()
				gpu_set_tex_filter(_gpu_tex_filter)
				shader_reset()
				_world_canvas.Finish()
				
				if instance_exists(sky) and sky.model != undefined {
					var _sky_canvas = _canvases[Canvases.SKY]
					
					with _sky_canvas {
						Resize(_width, _height)
						Start()
					}
					
					camera_set_view_mat(_render_camera, _view_matrix)
					camera_set_proj_mat(_render_camera, _projection_matrix)
					camera_apply(_render_camera)
					_gpu_tex_filter = gpu_get_tex_filter()
					gpu_set_tex_filter(_vid_texture_filter)
					gpu_set_zwriteenable(false)
					global.sky_shader.set()
					
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
					gpu_set_tex_filter(_gpu_tex_filter)
					
					with _sky_canvas {
						Finish()
						Draw(0, 0)
					}
				} else {
					_render_canvas.Clear(clear_color[4], clear_color[3])
				}
			}
			
			_world_canvas.Draw(0, 0)
			_render_canvas.Finish()
			
			if alpha >= 1 {
				_render_canvas.Draw(0, 0)
			} else {
				_render_canvas.DrawExt(0, 0, 1, 1, 0, c_white, global.delta * alpha)
			}
			
			output.Finish()
			
			if _allow_screen {
				output.Start()
				
				var _draw_priority = global.draw_priority
				var i = ds_list_size(_active_things)
				
				repeat i {
					with _active_things[| --i] {
						if f_visible {
							ds_priority_add(_draw_priority, id, screen_depth)
						}
					}
				}
				
				var _self = id
				
				repeat ds_priority_size(_draw_priority) {
					with ds_priority_delete_max(_draw_priority) {
						screen_camera = _self
						screen_width = _width
						screen_height = _height
						event_user(ThingEvents.DRAW_SCREEN)
					}
				}
				
				output.Finish()
			}
		}
		
		return output
	}
#endregion