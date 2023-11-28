function flags_force_clear(_scope) {
	gml_pragma("forceinline")
	
	with _scope {
		if slot == 0 {
			ds_map_copy(flags, global.default_flags)
		} else {
			ds_map_clear(flags)
		}
	}
}