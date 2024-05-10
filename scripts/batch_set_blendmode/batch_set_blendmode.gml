/// @desc Sets the current alpha testing threshold of the batch. This can cause batch breaks!
function batch_set_blendmode(_blendmode) {
	gml_pragma("forceinline")
	
	if _blendmode != global.batch_blendmode {
		batch_submit()
		global.batch_blendmode = _blendmode
	}
}