function ui_exists(_ui) {
	gml_pragma("forceinline")
	
	return is_instanceof(_ui, UI) and _ui.exists
}