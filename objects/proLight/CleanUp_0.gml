event_inherited()

if handle != -1 {
	area.lights[| handle] = false
	buffer_poke(light_data, offset + LightData.ACTIVE, buffer_f32, false)
}