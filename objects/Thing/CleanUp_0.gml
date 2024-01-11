if instance_exists(holding) {
	do_unhold(true, false)
}

if instance_exists(holder) {
	holder.do_unhold(true, false)
}

if clean_up != undefined {
	clean_up.setSelf(self)
	clean_up()
}

if voice != undefined and audio_exists(voice) {
	audio_stop_sound(voice)
}

if emitter != undefined and audio_emitter_exists(emitter) {
	audio_emitter_free(emitter)
}

if area_thing != undefined {
	area_thing.thing = noone
}

if area != undefined {
	var _active_things = area.active_things
	
	ds_list_delete(_active_things, ds_list_find_index(_active_things, id))
	
	if collider != undefined {
		var _collidables = area.collidables
		
		ds_list_delete(_collidables, ds_list_find_index(_collidables, id))
	}
}

if level != undefined and sync_id != noone {
	var _syncables = level.syncables
	
	_syncables[# sync_id, 0] = noone
	_syncables[# sync_id, 1] = 0
	
	var i = ds_grid_width(_syncables)
	
	repeat i {
		if _syncables[# --i, 0] != noone {
			break
		}
		
		ds_grid_resize(_syncables, -~i, 2)
	}
}

if net_variables != undefined {
	ds_list_destroy(net_variables)
}

if model != undefined {
	delete model
}

if collider != undefined {
	delete collider
}