function batch_set_properties(_alpha_test = 0, _bright = 0, _blendmode = bm_normal) {
	gml_pragma("forceinline")
	
	batch_set_alpha_test(_alpha_test)
	batch_set_bright(_bright)
	batch_set_blendmode(_blendmode)
}