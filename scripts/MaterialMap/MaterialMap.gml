function MaterialMap() : AssetMap() constructor {
	static load = function (_name, _strict = false) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "materials/" + _name
		
		// All material properties (and default values)
		var _image = -1
		var _image2 = undefined
		var _alpha_test = 0.5
		var _speed = 0
		var _bright = 0
		var _x_scroll = 0
		var _y_scroll = 0
		var _specular = 0
		var _specular_exponent = 1
		var _rimlight = 0
		var _rimlight_exponent = 1
		var _wind = 0
		var _wind_lock_bottom = 1
		var _wind_speed = 1
		var _color = [1, 1, 1, 1, c_white]
		
		var _json = json_load(mod_find_file(_path + ".*"))
		
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
			_rimlight = _json[$ "rimlight"] ?? 0
			_rimlight_exponent = _json[$ "rimlight_exponent"] ?? 1
			_wind = _json[$ "wind"] ?? 0
			_wind_lock_bottom = _json[$ "wind_lock_bottom"] ?? 1
			_wind_speed = _json[$ "wind_speed"] ?? 1
			_color = color_to_vec5(_json[$ "color"])
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
			rimlight = _rimlight
			rimlight_exponent = _rimlight_exponent
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