/// @description Draw
if handle != -1 {
	buffer_seek(light_data, buffer_seek_start, offset + LightData.ACTIVE)
	buffer_write(light_data, buffer_f32, active)
	buffer_write(light_data, buffer_f32, sx)
	buffer_write(light_data, buffer_f32, sy)
	buffer_write(light_data, buffer_f32, sz)
	buffer_write(light_data, buffer_f32, sarg0)
	buffer_write(light_data, buffer_f32, sarg1)
	buffer_write(light_data, buffer_f32, sarg2)
}