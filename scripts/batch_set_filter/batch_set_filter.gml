/// @desc Sets texture filtering on the batch. This can cause batch breaks!
function batch_set_filter(_filter) {
	gml_pragma("forceinline")
	
	if _filter != global.batch_filter {
		batch_submit()
		global.batch_filter = _filter
	}
}