/// @description Draw
if emitter != undefined and audio_emitter_exists(emitter) {
	audio_emitter_position(emitter, sx, sy, sz)
}

if model != undefined {
	var _draw = true
	
	if f_holdable_in_hand and instance_exists(holder) {
		var _parent_model = holder.model
		
		if _parent_model != undefined {
			var _hold_bone = _parent_model.hold_bone
			
			if _hold_bone != -1 {
				with model {
					var _mwp = matrix_get(matrix_world)
					
					matrix_build_dq(_parent_model.get_bone_dq(_hold_bone), matrix)
				
					var _offset_matrix = matrix_build(hold_offset_x, hold_offset_y, hold_offset_z, 0, 0, 0, 1, 1, 1)
					var _hold_matrix = matrix_multiply(_offset_matrix, matrix)
					
					matrix_set(matrix_world, matrix_multiply(_hold_matrix, _parent_model.matrix))
					submit()
					matrix_set(matrix_world, _mwp)
				}
				
				_draw = false
			}
		}
	}
	
	if _draw {
		model.draw()
	}
}

if draw != undefined {
	draw.setSelf(self)
	draw()
}

if m_shadow and shadow_ray[RaycastData.HIT] {
	var _radius = shadow_radius * 2
	
	batch_set_alpha_test(0)
	batch_set_bright(0)
	batch_floor_ext(imgShadow, 0, _radius, _radius, sshadow_x, sshadow_y, sshadow_z + 0.0625, shadow_ray[RaycastData.NX], shadow_ray[RaycastData.NY], shadow_ray[RaycastData.NZ], c_black, 0.5)
}