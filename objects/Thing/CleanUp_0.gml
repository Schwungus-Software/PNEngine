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
	
	ds_list_delete(_active_things, ds_list_find_index(_active_things, id))
	
	if collider != undefined {
		var _collidables = area.collidables
		
		ds_list_delete(_collidables, ds_list_find_index(_collidables, id))
	}
}

if model != undefined {
	model.sync_with(undefined)
	
	delete model
}

if collider != undefined {
	delete collider
}