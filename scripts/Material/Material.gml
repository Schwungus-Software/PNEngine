function Material() : Asset() constructor {
	static blank_textures = [[-1, 0, 0, 1, 1]]
	
	image = -1
	image2 = undefined
	textures = blank_textures
	frame_speed = 1
	
	alpha_test = 0.5
	
	bright = 0
	
	x_scroll = 0
	y_scroll = 0
	
	specular = 0
	specular_exponent = 1
	
	wind = 0
	wind_lock_bottom = 1
	wind_speed = 1
	
	color = undefined
}