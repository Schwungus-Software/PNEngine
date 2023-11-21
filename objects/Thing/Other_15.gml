/// @description Draw
if emitter != undefined and audio_emitter_exists(emitter) {
	audio_emitter_position(emitter, sx, sy, sz)
}

if model != undefined {
	model.draw()
}

if m_shadow and shadow_ray[RaycastData.HIT] {
	var _radius = shadow_radius * 2
	
	batch_set_alpha_test(0)
	batch_set_bright(0)
	batch_floor_ext(imgShadow, 0, _radius, _radius, sshadow_x, sshadow_y, sshadow_z + 0.0625, shadow_ray[RaycastData.NX], shadow_ray[RaycastData.NY], shadow_ray[RaycastData.NZ], c_black, 0.5)
}

if draw != undefined {
	draw.setSelf(self)
	draw()
}