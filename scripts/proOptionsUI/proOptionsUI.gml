function proOptionsUI() : UI(undefined) constructor {
	font = global.ui_font ?? -1
	switch_sound = global.switch_sound
	select_sound = global.select_sound
	fail_sound = global.fail_sound
	back_sound = global.back_sound
	
#region Main Menu
	main_menu = new OUIMenu("options.title", [
#region Controls
		new OUIMenu("options.controls.title", [
			new OUIOption("options.controls.in_invert_x", OUIValues.NO_YES, 0, global.config.in_invert_x, function (_value) {
				global.config.in_invert_x = _value
			}),
			
			new OUIOption("options.controls.in_invert_y", OUIValues.NO_YES, 0, global.config.in_invert_y, function (_value) {
				global.config.in_invert_y = _value
			}),
			
			new OUIOption("options.controls.in_pan_x", OUIValues.SENSITIVITY, 5, global.config.in_pan_x - 1, function (_value) {
				global.config.in_pan_x = -~_value
			}),
			
			new OUIOption("options.controls.in_pan_y", OUIValues.SENSITIVITY, 5, global.config.in_pan_y - 1, function (_value) {
				global.config.in_pan_y = -~_value
			}),
			
			undefined,
			new OUIBinding("options.controls.up", "up"),
			new OUIBinding("options.controls.left", "left"),
			new OUIBinding("options.controls.down", "down"),
			new OUIBinding("options.controls.right", "right"),
			new OUIBinding("options.controls.walk", "walk"),
			new OUIBinding("options.controls.jump", "jump"),
			new OUIBinding("options.controls.interact", "interact"),
			new OUIBinding("options.controls.attack", "attack"),
			undefined,
			new OUIBinding("options.controls.aim", "aim"),
			new OUIBinding("options.controls.aim_up", "aim_up"),
			new OUIBinding("options.controls.aim_left", "aim_left"),
			new OUIBinding("options.controls.aim_down", "aim_down"),
			new OUIBinding("options.controls.aim_right", "aim_right"),
			undefined,
			new OUIBinding("options.controls.inventory_up", "inventory_up"),
			new OUIBinding("options.controls.inventory_left", "inventory_left"),
			new OUIBinding("options.controls.inventory_down", "inventory_down"),
			new OUIBinding("options.controls.inventory_right", "inventory_right"),
		]),
#endregion
		
#region Video
		new OUIMenu("options.video.title", [
			new OUIOption("options.video.vid_fullscreen", OUIValues.OFF_ON, 0, global.config.vid_fullscreen, function (_value) {
				var _config = global.config
				
				_config.vid_fullscreen = _value
				display_set(_value, _config.vid_width, _config.vid_height)
			}),
			
			new OUIOption("options.video.vid_resolution", OUIValues.RESOLUTION, 7, function () {
				var _config = global.config
				var _width, _height
				
				with _config {
					_width = vid_width
					_height = vid_height
				}
				
				var _resolution = 0
				var _aspect = (_width / _height) >= (16 / 9)
				
				if _height >= 2160 {
					_resolution = 16
				} else if _height >= 1440 {
					_resolution = 14
				} else if _height >= 1080 {
					_resolution = 12
				} else if _height >= 900 {
					_resolution = 10
				} else if _height >= 720 {
					_resolution = 8
				} else if _height >= 540 {
					_resolution = 6
				} else if _height >= 480 {
					_resolution = 4
				} else if _height >= 270 {
					_resolution = 2
				}
				
				return _resolution + _aspect
			}(), function (_value) {
				var _width, _height
				
				switch _value {
					case 0:
						_width = 320
						_height = 240
					break
					
					case 1:
						_width = 426
						_height = 240
					break
					
					case 2:
						_width = 360
						_height = 270
					break
					
					case 3:
						_width = 480
						_height = 270
					break
					
					case 4:
						_width = 640
						_height = 480
					break
					
					case 5:
						_width = 854
						_height = 480
					break
					
					case 6:
						_width = 720
						_height = 540
					break
					
					case 7:
						_width = 960
						_height = 540
					break
					
					case 8:
						_width = 960
						_height = 720
					break
					
					case 9:
						_width = 1280
						_height = 720
					break
					
					case 10:
						_width = 1200
						_height = 900
					break
					
					case 11:
						_width = 1600
						_height = 900
					break
					
					case 12:
						_width = 1440
						_height = 1080
					break
					
					case 13:
						_width = 1920
						_height = 1080
					break
					
					case 14:
						_width = 1920
						_height = 1440
					break
					
					case 15:
						_width = 2560
						_height = 1440
					break
					
					case 16:
						_width = 2880
						_height = 2160
					break
					
					case 17:
						_width = 3840
						_height = 2160
					break
				}
				
				with global.config {
					vid_width = _width
					vid_height = _height
				}
			}),
			
			new OUIOption("options.video.vid_max_fps", OUIValues.FRAMERATE, 1, function () {
				var _fps = global.config.vid_max_fps
				var _preset = 0
				
				if _fps >= 240 {
					_preset = 6
				} else if _fps >= 165 {
					_preset = 5
				} else if _fps >= 144 {
					_preset = 4
				} else if _fps >= 120 {
					_preset = 3
				} else if _fps >= 75 {
					_preset = 2
				} else if _fps >= 60 {
					_preset = 1
				}
				
				return _preset
			}(), function (_value) {
				var _fps
				
				switch _value {
					case 0:
						_fps = 30
					break
					
					case 1:
						_fps = 60
					break
					
					case 2:
						_fps = 75
					break
					
					case 3:
						_fps = 120
					break
					
					case 4:
						_fps = 144
					break
					
					case 5:
						_fps = 165
					break
					
					case 6:
						_fps = 240
					break
				}
				
				global.config.vid_max_fps = _fps
				game_set_speed(_fps, gamespeed_fps)
			}),
			
			new OUIOption("options.video.vid_vsync", OUIValues.OFF_ON, 0, global.config.vid_vsync, function (_value) {
				var _config = global.config
				
				_config.vid_vsync = _value
				display_reset(_config.vid_antialias, _value)
			}),
			
			undefined,
			
			new OUIOption("options.video.vid_texture_filter", OUIValues.TEXTURE, 1, global.config.vid_texture_filter, function (_value) {
				global.config.vid_texture_filter = _value
			}),
			
			new OUIOption("options.video.vid_antialias", OUIValues.ANTIALIAS, 0, function () {
				var _aa = global.config.vid_antialias
				var _preset = 0
				
				if _aa >= 8 {
					_preset = 3
				} else if _aa >= 4 {
					_preset = 2
				} else if _aa >= 2 {
					_preset = 1
				}
				
				return _preset
			}(), function (_value) {
				var _aa = 0
				
				switch _value {
					case 1: _aa = 2 break
					case 2: _aa = 4 break
					case 3: _aa = 8 break
				}
				
				var _config = global.config
				
				_config.vid_antialias = _aa
				display_reset(_aa, _config.vid_vsync)
			}),
			
			new OUIOption("options.video.vid_bloom", OUIValues.OFF_ON, 1, global.config.vid_bloom, function (_value) {
				global.config.vid_bloom = _value
			}),
			
			undefined,
			
			new OUIOption("options.video.vid_lighting", OUIValues.LEVEL, 1, global.config.vid_lighting, function (_value) {
				global.config.vid_lighting = _value
			}),
			
			/*new OUIOption("options.video.vid_shadow", OUIValues.OFF_ON, 1, global.config.vid_shadow, function (_value) {
				global.config.vid_shadow = _value
			}),
			
			new OUIOption("options.video.vid_shadow_size", OUIValues.SHADOW_SIZE, 1, function () {
				var _size = global.config.vid_shadow_size
				var _preset = 0
				
				if _size >= 2048 {
					_preset = 4
				} else if _size >= 1024 {
					_preset = 3
				} else if _size >= 512 {
					_preset = 2
				} else if _size >= 256 {
					_preset = 1
				} else if _size >= 128 {
					_preset = 0
				}
				
				return _preset
			}(), function (_value) {
				var _size
				
				switch _value {
					case 0:
						_size = 128
					break
					
					case 1:
						_size = 256
					break
					
					case 2:
						_size = 512
					break
					
					case 3:
						_size = 1024
					break
					
					case 4:
						_size = 2048
					break
				}
				
				global.config.vid_shadow_size = _size
			}),*/
			
			undefined,
			
			new OUIButton("options.video.apply", function () {
				var _config = global.config
				
				display_set(_config.vid_fullscreen, _config.vid_width, _config.vid_height)
				
				return true
			}),
		]),
#endregion
		
#region Audio
		new OUIMenu("options.audio.title", [
			new OUIOption("options.audio.snd_volume", OUIValues.VOLUME, 20, floor(clamp(global.config.snd_volume, 0, 1) * 20), function (_value) {
				var _volume = _value * 0.05
				
				master_set_volume(_volume)
				global.config.snd_volume = _volume
			}),
			
			new OUIOption("options.audio.snd_sound_volume", OUIValues.VOLUME, 20, floor(clamp(global.config.snd_sound_volume, 0, 1) * 20), function (_value) {
				var _volume = _value * 0.05
				
				sound_set_volume(_volume)
				global.config.snd_sound_volume = _volume
			}),
			
			new OUIOption("options.audio.snd_music_volume", OUIValues.VOLUME, 20, floor(clamp(global.config.snd_music_volume, 0, 1) * 20), function (_value) {
				var _volume = _value * 0.05
				
				music_set_volume(_volume)
				global.config.snd_music_volume = _volume
			}),
			
			undefined,
			
			new OUIOption("options.audio.snd_background", OUIValues.NO_YES, 0, global.config.snd_background, function (_value) {
				global.config.snd_background = _value
			}),
		]),
		
		undefined,
		
		new OUIMenu("options.confirm.save", [
			new OUIText("options.confirm.text"),
			undefined,
			
			new OUIButton("options.confirm.confirm", function () {
				config_save()
				config_update()
				replace(proOptionsUI).main_menu.option = other.main_menu.option
				
				return true
			}),
		]),
		
		new OUIMenu("options.confirm.last", [
			new OUIText("options.confirm.text"),
			undefined,
			
			new OUIButton("options.confirm.confirm", function () {
				config_load()
				config_update()
				replace(proOptionsUI).main_menu.option = other.main_menu.option
				
				return true
			}),
		]),
		
		new OUIMenu("options.confirm.default", [
			new OUIText("options.confirm.text"),
			undefined,
			
			new OUIButton("options.confirm.confirm", function () {
				config_reset()
				config_update()
				replace(proOptionsUI).main_menu.option = other.main_menu.option
				
				return true
			}),
		]),
	])
#endregion
#endregion
	
	menu = main_menu
	focus = undefined
	force_option = -1
	
	clean_up = function () {
		input_binding_scan_abort()
	}
	
	tick = function () {
		if focus != undefined {
			input_verb_consume("jump")
			input_verb_consume("leave")
			input_verb_consume("debug_console")
			
			if input[UIInputs.BACK] {
				if input_binding_scan_in_progress() {
					input_binding_scan_abort()
			    } else {
					play_sound(back_sound)
				}
				
				focus = undefined
				
				exit
			}
			
			if is_instanceof(focus, OUIInput) and input[UIInputs.CONFIRM] {
				play_sound(focus.confirm(keyboard_string) ? select_sound : fail_sound)
				focus = undefined
			}
			
			exit
		}
		
		if input[UIInputs.BACK] {
			play_sound(back_sound)
			
			var _from = menu.from
			
			if _from == undefined {
				destroy()
			} else {
				menu = _from
			}
			
			exit
		}
		
		if force_option >= 0 {
			menu.option = force_option
			force_option = -1
		} else {
			var _up_down = input[UIInputs.UP_DOWN]
		
			if _up_down != 0 {
				var _changed = false
			
				with menu {
					var n = array_length(contents)
				
					if not n {
						break
					}
				
					var _next = option
				
					while true {
						option = (option + _up_down) % n
					
						while option < 0 {
							option += n
						}
					
						var _option = contents[option]
					
						if is_instanceof(_option, OUIElement) and not _option.disabled {
							break
						}
					}
				
					_changed = _next != option
				}
			
				if _changed {
					play_sound(switch_sound)
				}
			}
		}
		
		var _left_right = input[UIInputs.LEFT_RIGHT] + input[UIInputs.CONFIRM]
		
		if _left_right != 0 {
			var _selected = false
			
			with menu {
				var _option = contents[option]
				
				if not is_instanceof(_option, OUIOption) or _option.disabled {
					break
				}
				
				_selected = _option.select(_left_right)
			}
			
			play_sound(_selected ? select_sound : fail_sound)
		}
		
		if input[UIInputs.CONFIRM] {
			var _changed = false
			
			with menu {
				var _option = contents[option]
				
				if is_instanceof(_option, OUIMenu)  {
					if _option.disabled {
						break
					}
					
					_option.from = other.menu
					other.menu = _option
					_changed = true
				} else if is_instanceof(_option, OUIButton) {
					_changed = _option.select(0)
				} else if is_instanceof(_option, OUIInput) {
					keyboard_string = string(_option.current_value)
					other.focus = _option
					_changed = true
				} else if is_instanceof(_option, OUIBinding) {
					with other {
						static _ignore = [vk_escape, vk_backspace, 192]
						
						focus = _option
						input_binding_scan_params_set(_ignore)
						
						input_binding_scan_start(function (_binding) {
			                input_binding_set_safe(focus.verb, _binding)
							play_sound(select_sound)
							focus = undefined
							input_verb_consume(all)
			            }, function () {
							play_sound(back_sound)
							focus = undefined
						})
					}
					
					_changed = true
				}
			}
			
			if _changed {
				play_sound(select_sound)
			}
		}
	}
	
	draw_gui = function () {
		draw_set_alpha(0.5)
		draw_rectangle_color(0, 0, 480, 270, c_black, c_black, c_black, c_black, false)
		draw_set_alpha(1)
		
		var _font = font
		
		draw_set_font(_font)
		draw_set_valign(fa_center)
		
		var _focus = focus
		
		with menu {
			var i = 0
			var _margin = string_height(" ") + 1
			var _y = 135 - (option * _margin)
			
			repeat array_length(contents) {
				var _element = contents[i]
				
				if _element == undefined {
					_y += _margin;
					++i
					
					continue
				}
				
				var _color = is_instanceof(_element, OUIText) ? c_white : (option == i ? c_yellow : C_AB_GREEN)
				
				with _element {
					var _name = lexicon_text(name)
					
					draw_text_color(24, _y, _name, _color, _color, _color, _color, 1)
					
					if is_instanceof(_element, OUIOption) {
						draw_text(32 + string_width(_name), _y, lexicon_text(values[current_value]))
					} else if is_instanceof(_element, OUIInput) {
						var _text
						
						if _focus == _element {
							_text = keyboard_string
							
							if (current_time % 1000) >= 500 {
								_text += "|"
							}
						} else {
							_text = current_value
						}
						
						draw_text(32 + string_width(_name), _y, _text)
					} else if is_instanceof(_element, OUIBinding) {
						var _text = _focus == _element ? lexicon_text("value.press_any_key") : string_input(verb)
						
						draw_text(32 + string_width(_name), _y, _text)
					}
				}
				
				_y += _margin;
				++i
			}
		}
		
		draw_set_valign(fa_top)
		draw_set_halign(fa_right)
		draw_text_transformed(448, 32, lexicon_text(menu.name), 2, 2, 0)
		
		var _indicator = ""
		
		if focus != undefined {
			if is_instanceof(focus, OUIInput) {
				_indicator += $"[{string_input("ui_enter")}] {lexicon_text("options.hud.confirm")}"
			}
			
			_indicator += $"\n\n[{string_input("pause")}] {lexicon_text("options.hud.cancel")}"
		} else {
			_indicator += $"[{string_input("ui_up")}/{string_input("ui_down")}] {lexicon_text("options.hud.select")}"
			_indicator += $"\n\n[{string_input("ui_left")}/{string_input("ui_right")}] {lexicon_text("options.hud.change")}"
			_indicator += $"\n\n[{string_input("ui_enter")}] {lexicon_text("options.hud.confirm")}"
			_indicator += $"\n\n[{string_input("pause")}] {lexicon_text(menu.from != undefined ? "options.hud.back" : "options.hud.exit")}"
		}
		
		draw_set_valign(fa_middle)
		draw_text_color(448, 135, _indicator, c_ltgray, c_ltgray, c_ltgray, c_ltgray, 0.64)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_font(-1)
	}
}