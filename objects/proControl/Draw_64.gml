draw_clear(c_black)

var _draw_target = global.ui

if _draw_target != undefined {
	while true {
		var _child = _draw_target.child
		
		if _child == undefined {
			break
		}
		
		_draw_target = _child
	}
}

if _draw_target == undefined or _draw_target.f_draw_screen {
	var _width = window_get_width()
	var _height = window_get_height()
	
#region Draw Active Cameras
	var _players = global.players
	var _camera_active = global.camera_active
	
	if instance_exists(_camera_active) {
		_camera_active.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
	} else {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active {
					with _players[local_slot] {
						if instance_exists(camera) {
							camera.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
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
								camera.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
							
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
						with _players[i] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height, i == 0).DrawStretched(0, _y, 480, 135)
							}
						}
						
						_y += 135;
						++i
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
						with _players[i] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height, i == 0).DrawStretched(_x, _y, 240, 135)
							}
						}
						
						_x += 240
						
						if _x > 240 {
							_x = 0
							_y += 135
						}
						
						++i
					}
				break
			}
		}
	}
#endregion
	
	var _console = global.console
	
#region Update Particles & Draw GUI
	var _dead_particles = global.dead_particles
	var _particle_step = not (global.freeze_step or _console)
	var d = global.delta
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
		
		var _things = _area.active_things
		var j = ds_list_size(_things)
		
		repeat j {
			with _things[| --j] {
				if f_visible {
					gpu_set_depth(gui_depth)
					event_user(ThingEvents.DRAW_GUI)
				}
			}
		}
		
		gpu_set_depth(0)
	}
#endregion
}

// Draw UI
if _draw_target != undefined {
	with _draw_target {
		if draw_gui != undefined {
			draw_gui(_draw_target)
		}
	}
}

with proTransition {
	event_user(ThingEvents.DRAW_GUI)
}

var _netgame = global.netgame

if _netgame != undefined and _netgame.active {
	draw_set_font(chat_font)
	draw_set_valign(fa_bottom)
	
	var _lines = MAX_CHAT_LINES
	var _typing = global.chat_typing
	var _y = 262
	
	if _typing {
		var _input = ">" + keyboard_string + (current_time % 1000 < 500 ? "_" : " ")
		var _width = string_width(_input)
		var _height = string_height(_input)
		var _x = _width > 464 ? 8 - (_width - 464) : 8
		
		draw_set_alpha(0.5)
		draw_rectangle_color(_x - 1, 262 - _height, _x + _width, 262, c_black, c_black, c_black, c_black, false)
		draw_set_alpha(1)
		draw_text(_x, 262, _input)
		_y -= _height + 1
		_lines *= 2
	}
	
	var _chat = global.chat
	var _chat_line_times = global.chat_line_times
	var i = ds_list_size(_chat)
	var j = 0
	
	if i {
		repeat _lines {
			if not _typing {
				if _chat_line_times[j] > 0 {
					_chat_line_times[j] -= d
				} else {
					++j
					
					continue
				}
				
				++j
			}
			
			i -= 2
			
			var _message = _chat[| i]
			var _color = _chat[| -~i]
			var _height = string_height_ext(_message, -1, 464)
			
			draw_set_alpha(0.5)
			draw_rectangle_color(7, _y - _height, 8 + string_width_ext(_message, -1, 464), _y, c_black, c_black, c_black, c_black, false)
			draw_set_alpha(1)
			draw_text_color(8, _y, _message, _color, _color, _color, _color, 1)
			_y -= _height + 1
			
			if i <= 0 {
				break
			}
		}
	}
	
	draw_set_valign(fa_top)
	draw_set_font(-1)
	
	if caption_time > 0 {
		caption.align(fa_right, fa_bottom).draw(450, 240)
		caption_time -= d
	}
} else {
	if caption_time > 0 {
		caption.align(fa_center, fa_bottom).draw(240, 240)
		caption_time -= d
	}
}

if _console {
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
	
	var _input = keyboard_string
	
	if current_time % 1000 < 500 {
		_input += "_"
	}
	
	var _x = string_width(_input) * 0.5
	
	_x = _x > 480 ? 480 - _x : 0
	draw_text_transformed(_x, _console_bottom, _input, 0.5, 0.5, 0)
	draw_set_font(-1)
}

if load_state != LoadStates.NONE and load_level != undefined {
	scribble($"[{ui_font_name}][wave][fa_center][fa_middle]{lexicon_text("loading")}", "__PNENGINE_LOADING__").draw(240, 135)
}

fmod_system_update()