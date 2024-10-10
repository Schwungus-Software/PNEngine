if instance_exists(holding) {
	do_unhold(false, true)
}

if instance_exists(holder) {
	holder.do_unhold(false, true)
}

if clean_up != undefined {
	catspeak_execute(clean_up)
}

if voice != undefined and fmod_channel_control_is_playing(voice) {
	fmod_channel_control_stop(voice)
}

if emitter != undefined {
	fmod_channel_control_stop(emitter)
	fmod_channel_group_release(emitter)
}

if area_thing != undefined {
	area_thing.thing = noone
}

if area != undefined {
	var _active_things = area.active_things
	
	ds_list_delete(_active_things, ds_list_find_index(_active_things, self))
	
	var _tick_things = area.tick_things
	var _index = ds_list_find_index(_tick_things, self)
	
	if _index != -1 {
		ds_list_delete(_tick_things, _index)
	}
	
	var _tick_colliders = area.tick_colliders
	
	_index = ds_list_find_index(_tick_colliders, self)
	
	if _index != -1 {
		ds_list_delete(_tick_colliders, _index)
	}
}

if model != undefined {
	model.sync_with(undefined)
	
	delete model
}

if collider != undefined {
	delete collider
}