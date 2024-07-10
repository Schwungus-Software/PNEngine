/// @description Draw
if handle != -1 {
	light_data[offset + LightData.ACTIVE] = active
	light_data[offset + LightData.X] = sx
	light_data[offset + LightData.Y] = sy
	light_data[offset + LightData.Z] = sz
	light_data[offset + LightData.ARG0] = sarg0
	light_data[offset + LightData.ARG1] = sarg1
	light_data[offset + LightData.ARG2] = sarg2
	light_data[offset + LightData.ARG3] = sarg3
	light_data[offset + LightData.ARG4] = sarg4
	light_data[offset + LightData.ARG5] = sarg5
	light_data[offset + LightData.RED] = color_get_red(color) * COLOR_INVERSE
	light_data[offset + LightData.GREEN] = color_get_green(color) * COLOR_INVERSE
	light_data[offset + LightData.BLUE] = color_get_blue(color) * COLOR_INVERSE
	light_data[offset + LightData.ALPHA] = alpha
}