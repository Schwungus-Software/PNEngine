/// @description Draw
/*if emitter != undefined and audio_emitter_exists(emitter) {
	//audio_emitter_position(emitter, sx, sy, sz)
}*/

var _model = model

if _model != undefined and (not instance_exists(holder) or not f_holdable_in_hand) {
	_model.draw()
	
	if instance_exists(holding) and holding.f_holdable_in_hand {
		var _hold_bone = _model.hold_bone
		
		if _hold_bone != -1 {
			with holding {
				if model == undefined {
					break
				}
				
				with model {
					var _mwp = matrix_get(matrix_world)
					
					matrix_build_dq(_model.get_bone_dq(_hold_bone), matrix)
					
					var _hold_matrix = matrix_multiply(hold_offset_matrix, matrix)
					
					matrix = matrix_multiply(_hold_matrix, _model.matrix)
					matrix_set(matrix_world, matrix)
					submit()
					matrix_set(matrix_world, _mwp)
				}
			}
		}
	}
}

if draw != undefined {
	draw(id)
}

if m_shadow and shadow_ray[RaycastData.HIT] {
	var _radius = shadow_radius * 2
	
	batch_set_alpha_test(0)
	batch_set_bright(0)
	batch_floor_ext(imgShadow, 0, _radius, _radius, sshadow_x, sshadow_y, sshadow_z + 0.0625, shadow_ray[RaycastData.NX], shadow_ray[RaycastData.NY], shadow_ray[RaycastData.NZ], c_black, 0.5)
}