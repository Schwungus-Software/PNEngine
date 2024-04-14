/// @description Create
event_inherited()

light_data = area.light_data

var _color = undefined

if is_struct(special) {
	_color = special[$ "color"]
	active = special[$ "active"] ?? active
}

if _color != undefined {
	// integer
	if is_real(_color) {
		color = _color
	}
	
	// vec2, vec3 or vec4
	if is_array(_color) {
		switch array_length(_color) {
			case 2:
				color = _color[0]
				alpha = _color[1]
				
				if not is_real(color) or not is_real(alpha) {
					show_error("!!! proLight: Invalid vec2 array, elements must be real", true)
				}
			break
			
			case 3:
				var _r = _color[0]
				var _g = _color[1]
				var _b = _color[2]
				
				if not is_real(_r) or not is_real(_g) or not is_real(_b) {
					show_error("!!! proLight: Invalid vec3 array, elements must be real", true)
				}
				
				color = make_color_rgb(_r * 255, _g * 255, _b * 255)
			break
				
			case 4:
				var _r = _color[0]
				var _g = _color[1]
				var _b = _color[2]
				
				alpha = _color[3]
				
				if not is_real(_r) or not is_real(_g) or not is_real(_b) or not is_real(alpha) {
					show_error("!!! proLight: Invalid vec4 array, elements must be real", true)
				}
				
				color = make_color_rgb(_r * 255, _g * 255, _b * 255)
			break
		}
	}
}

var _lights = area.lights

handle = ds_list_find_index(_lights, false)

if handle != -1 {
	_lights[| handle] = true
	offset = handle * LightData.__SIZE
	
	buffer_seek(light_data, buffer_seek_start, offset)
	buffer_write(light_data, buffer_f32, type)
	buffer_write(light_data, buffer_f32, active)
	buffer_write(light_data, buffer_f32, x)
	buffer_write(light_data, buffer_f32, y)
	buffer_write(light_data, buffer_f32, z)
	buffer_write(light_data, buffer_f32, arg0)
	buffer_write(light_data, buffer_f32, arg1)
	buffer_write(light_data, buffer_f32, arg2)
	buffer_write(light_data, buffer_f32, color_get_red(color) * COLOR_INVERSE)
	buffer_write(light_data, buffer_f32, color_get_green(color) * COLOR_INVERSE)
	buffer_write(light_data, buffer_f32, color_get_blue(color) * COLOR_INVERSE)
	buffer_write(light_data, buffer_f32, alpha)
}