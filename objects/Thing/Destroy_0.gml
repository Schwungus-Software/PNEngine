if area_thing != undefined {
	if f_disposable {
		area_thing.disposed = true
	}
}

if on_destroy != undefined {
	catspeak_execute_id(on_destroy)
}