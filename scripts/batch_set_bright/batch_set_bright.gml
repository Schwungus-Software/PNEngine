/// @desc Sets the current brightness of the batch. This can cause batch breaks!
function batch_set_bright(_bright) {
	gml_pragma("forceinline")
	
	if _bright != global.batch_bright {
		batch_submit()
		global.batch_bright = _bright
	}
}