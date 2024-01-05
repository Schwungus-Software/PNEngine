function mod_find_file(_filename) {
	var _mods = global.mods
	var _key = ds_map_find_last(_mods)
	
	repeat ds_map_size(_mods) {
		var _path = _mods[? _key].path + _filename
		
		if file_exists(_path) {
			return _path
		}
		
		_key = ds_map_find_previous(_mods, _key)
	}
	
	return ""
}