/// @description Create
event_inherited()

light_data = area.light_data

var _color = undefined

if is_struct(special) {
	_color = special[$ "color"]
	active = special[$ "active"] ?? active
	
	if (special[$ "shadow"] ?? false) and global.config.vid_shadow {
		shadow_camera = area.add(Camera, x, y, z)
		shadow_camera.output.SetFormat(surface_r32float)
	}
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
	light_data[offset + LightData.TYPE] = type
	light_data[offset + LightData.ACTIVE] = active
	light_data[offset + LightData.X] = x
	light_data[offset + LightData.Y] = y
	light_data[offset + LightData.Z] = z
	light_data[offset + LightData.ARG0] = arg0
	light_data[offset + LightData.ARG1] = arg1
	light_data[offset + LightData.ARG2] = arg2
	light_data[offset + LightData.RED] = color_get_red(color) * COLOR_INVERSE
	light_data[offset + LightData.GREEN] = color_get_green(color) * COLOR_INVERSE
	light_data[offset + LightData.BLUE] = color_get_blue(color) * COLOR_INVERSE
	light_data[offset + LightData.ALPHA] = alpha
}