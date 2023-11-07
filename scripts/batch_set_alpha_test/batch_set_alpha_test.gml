/// @desc Sets the current alpha testing threshold of the batch. This can cause batch breaks!
function batch_set_alpha_test(_threshold) {
	gml_pragma("forceinline")
	
	if _threshold != global.batch_alpha_test {
		batch_submit()
		global.batch_alpha_test = _threshold
	}
}