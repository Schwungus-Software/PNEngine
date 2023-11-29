draw_clear(c_black)

var _players = global.players

#region Draw Active Cameras
	var _width = window_get_width()
	var _height = window_get_height()
	var _camera_active = global.camera_active
	
	if instance_exists(_camera_active) {
		_camera_active.render(_width, _height).DrawStretched(0, 0, 480, 270)
	} else {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active {
					with _players[local_slot] {
						if instance_exists(camera) {
							camera.render(_width, _height).DrawStretched(0, 0, 480, 270)
						}
					}
				}
			}
		} else {
			switch global.players_active {
				case 1:
					var i = 0
				
					repeat INPUT_MAX_PLAYERS {
						with _players[i++] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height).DrawStretched(0, 0, 480, 270)
							
								break
							}
						}
					}
				break
			
				case 2:
					_height *= 0.5
					
					var _y = 0
					var i = 0
				
					repeat INPUT_MAX_PLAYERS {
						with _players[i++] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height).DrawStretched(0, _y, 480, 135)
							}
						}
						
						_y += 135
					}
				break
			
				case 3:
				case 4:
					_width *= 0.5
					_height *= 0.5
					
					var _x = 0
					var _y = 0
					var i = 0
				
					repeat INPUT_MAX_PLAYERS {
						with _players[i++] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height).DrawStretched(_x, _y, 240, 135)
							}
						}
					
						_x += 240
					
						if _x > 240 {
							_x = 0
							_y += 135
						}
					}
				break
			}
		}
	}
#endregion

#region Update Particles & Draw GUI
	var _dead_particles = global.dead_particles
	var _particle_step = not global.freeze_step
	var d = (delta_time * TICKRATE_DELTA) * global.tick_scale
	var _drawn_areas = 0
	var i = 0

	repeat INPUT_MAX_PLAYERS {
		var _player = _players[i++]
	
		if _player.status != PlayerStatus.ACTIVE {
			continue
		}
	
		var _area = _player.area
	
		if _area == undefined {
			continue
		}
	
		var _area_mask = 1 << _area.slot
	
		if _drawn_areas & _area_mask {
			continue
		}
		
		_drawn_areas |= _area_mask
		
		if _particle_step {
			var _particles = _area.particles
			var j = ds_list_size(_particles)
			
			repeat j {
				var p = _particles[| --j]
				
				p[ParticleData.TICKS] -= d
				p[ParticleData.X] += p[ParticleData.X_SPEED] * d
				p[ParticleData.Y] += p[ParticleData.Y_SPEED] * d
				
				var _z_speed = p[ParticleData.Z_SPEED]
				var _z = p[ParticleData.Z] + _z_speed * d
				
				p[ParticleData.Z] = _z
				p[ParticleData.X_SPEED] *= power(p[ParticleData.X_FRICTION], d)
				p[ParticleData.Y_SPEED] *= power(p[ParticleData.Y_FRICTION], d)
				p[ParticleData.Z_SPEED] = clamp(_z_speed - (p[ParticleData.GRAVITY] * d), p[ParticleData.MAX_FALL_SPEED] * d, p[ParticleData.MAX_FLY_SPEED] * d) * power(p[ParticleData.Z_FRICTION], d)
				
				var _width = p[ParticleData.WIDTH] - p[ParticleData.WIDTH_SPEED] * d
				var _height = p[ParticleData.HEIGHT] - p[ParticleData.HEIGHT_SPEED] * d
				
				p[ParticleData.WIDTH] = _width
				p[ParticleData.HEIGHT] = _height
				p[ParticleData.ANGLE] += p[ParticleData.ANGLE_SPEED] * d
				
				var _alpha = p[ParticleData.ALPHA] - p[ParticleData.ALPHA_SPEED] * d
				
				p[ParticleData.ALPHA] = _alpha
				p[ParticleData.BRIGHT] = max(0, p[ParticleData.BRIGHT] - (p[ParticleData.BRIGHT_SPEED] * d))
				
				var _frame = p[ParticleData.FRAME] + p[ParticleData.FRAME_SPEED] * d
				var _animation = p[ParticleData.ANIMATION]
				
				if _animation == ParticleAnimations.PLAY_STAY {
					_frame = min(_frame, p[ParticleData.IMAGE].GetCount() - 1)
				}
				
				p[ParticleData.FRAME] = _frame
				
				if p[ParticleData.TICKS] <= 0 or (_animation == ParticleAnimations.PLAY and _frame >= p[ParticleData.IMAGE].GetCount()) or _width <= 0 or _height <= 0 or _alpha <= 0 or _z < p[ParticleData.FLOOR_Z] or _z > p[ParticleData.CEILING_Z] {
					p[ParticleData.DEAD] = true
				}
				
				if p[ParticleData.DEAD] {
					ds_stack_push(_dead_particles, p)
					ds_list_delete(_particles, j)
				}
			}
		}
		
		var _draw_priority = global.draw_priority
		var _things = _area.active_things
		var j = ds_list_size(_things)
		
		repeat j {
			var _thing = _things[| --j]
		
			ds_priority_add(_draw_priority, _thing, _thing.gui_depth)
		}
	
		repeat ds_priority_size(_draw_priority) {
			with ds_priority_delete_max(_draw_priority) {
				event_user(ThingEvents.DRAW_GUI)
			}
		}
	}
#endregion

with proTransition {
	event_user(ThingEvents.DRAW_GUI)
}

if caption_time > 0 {
	caption.draw(240, 240)
	caption_time -= global.delta
}

if global.console {
	draw_set_font(scribble_fallback_font)
	
	var _console_bottom = 160
	
	draw_set_alpha(0.5)
	draw_rectangle_color(0, 0, 480, _console_bottom + 8, c_black, c_black, c_black, c_black, false)
	draw_set_alpha(1)
	
	var _console_log = global.console_log
	var n = ds_list_size(_console_log)
	var i = 0
	var _y = 0
	
	repeat 20 {
		if (_console_bottom - _y) < 0 {
			break
		}
		
		++i
		
		var _str = _console_log[| n - i]
		
		if _str == undefined {
			break
		}
		
		_y += string_height_ext(_str, -1, 960) * 0.5
		draw_text_ext_transformed(0, _console_bottom - _y, _str, -1, 960, 0.5, 0.5, 0)
	}
	
	var _input = input_string_get() + "_"
	var _x = string_width(_input) * 0.5
	
	_x = _x > 480 ? 480 - _x : 0
	draw_text_transformed(_x, _console_bottom, _input, 0.5, 0.5, 0)
	draw_set_font(-1)
}

if load_state != LoadStates.NONE and load_level != undefined {
	scribble("[fntHUD][wave][fa_center][fa_middle]" + lexicon_text("loading"), "__PNENGINE_LOADING__").draw(240, 135)
}