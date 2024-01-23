function master_set_volume(_volume) {
	gml_pragma("forceinline")
	
	global.master_volume = _volume
	audio_master_gain(_volume)
}