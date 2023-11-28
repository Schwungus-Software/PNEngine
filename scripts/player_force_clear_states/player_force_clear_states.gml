function player_force_clear_states(_scope) {
	gml_pragma("forceinline")
	
	with _scope {
		ds_map_clear(states)
		states[? "hp"] = 8
		states[? "coins"] = 0
		states[? "invincible"] = false
		states[? "frozen"] = false
	}
}