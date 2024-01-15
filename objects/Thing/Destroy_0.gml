if area_thing != undefined {
	if f_disposable {
		area_thing.disposed = true
	}
}

if on_destroy != undefined {
	on_destroy(id)
}