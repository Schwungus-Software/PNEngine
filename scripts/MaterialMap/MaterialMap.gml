function MaterialMap() : AssetMap() constructor {
	static load = function (_name, _strict = false) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "materials/" + _name
		var _image = -1
		var _image2 = undefined
		var _alpha_test = 0.5
		var _speed = 0
		var _bright = 0
		var _x_scroll = 0
		var _y_scroll = 0
		var _specular = 0
		var _specular_exponent = 1
		var _wind = 0
		var _wind_lock_bottom = 1
		var _wind_speed = 1
		var _color = [1, 1, 1, 1, c_white]
		var _json = json_load(mod_find_file(_path + ".json"))
		
		if is_struct(_json) {
			var _images = global.images
			
			_image = _json[$ "image"] ?? -1
			
			if is_string(_image) {
				_images.load(_image)
			}
			
			_image2 = _json[$ "image2"]
			
			if is_string(_image2) {
				_images.load(_image2)
			}
			
			_alpha_test = _json[$ "alpha_test"] ?? 0.5
			_speed = _json[$ "speed"] ?? 0
			_bright = _json[$ "bright"] ?? 0
			
			var _scroll = _json[$ "scroll"]
			
			if is_array(_scroll) and array_length(_scroll) >= 2 {
				_x_scroll = _scroll[0]
				_y_scroll = _scroll[1]
			}
			
			_specular = _json[$ "specular"] ?? 0
			_specular_exponent = _json[$ "specular_exponent"] ?? 1
			_wind = _json[$ "wind"] ?? 0
			_wind_lock_bottom = _json[$ "wind_lock_bottom"] ?? 1
			_wind_speed = _json[$ "wind_speed"] ?? 1
			
			var __color = _json[$ "color"]
			
			if is_array(__color) {
				if array_length(__color) == 2 {
					var _col = __color[0]
					
					_color[0] = color_get_red(_col) * COLOR_INVERSE
					_color[1] = color_get_green(_col) * COLOR_INVERSE
					_color[2] = color_get_blue(_col) * COLOR_INVERSE
					_color[3] = _color[1]
					_color[4] = _col
				} else {
					var _r = __color[0]
					var _g = __color[1]
					var _b = __color[2]
					
					_color[0] = __color[0]
					_color[1] = __color[1]
					_color[2] = __color[2]
					_color[3] = __color[3]
					_color[4] = make_color_rgb(_r * 255, _g * 255, _b * 255)
				}
			}
		} else {
			if _strict {
				print($"! MaterialMap.load: '{_name}' not found")
				
				exit
			}
		}
		
		var _material = new Material()
		
		with _material {
			name = _name
			image = _image
			image2 = _image2
			frame_speed = _speed
			alpha_test = _alpha_test
			bright = _bright
			x_scroll = _x_scroll
			y_scroll = _y_scroll
			specular = _specular
			specular_exponent = _specular_exponent
			wind = _wind
			wind_lock_bottom = _wind_lock_bottom
			wind_speed = _wind_speed
			color = _color
		}
		
		ds_map_add(assets, _name, _material)
		print($"MaterialMap.load: Added '{_name}' ({_material})")
	}
}

global.materials = new MaterialMap()