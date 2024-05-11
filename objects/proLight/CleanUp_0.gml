event_inherited()

if handle != -1 {
	area.lights[| handle] = noone
	
	var i = 0
	
	repeat LightData.__SIZE {
		light_data[offset + i++] = 0
	}
}