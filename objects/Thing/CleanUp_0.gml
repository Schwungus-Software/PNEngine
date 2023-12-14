if clean_up != undefined {
	clean_up.setSelf(self)
	clean_up()
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