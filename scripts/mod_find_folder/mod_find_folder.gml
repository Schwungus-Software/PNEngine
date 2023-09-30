function mod_find_folder(_folder) {
	var _mods = global.mods
	var _key = ds_map_find_first(_mods)
	
	repeat ds_map_size(_mods) {
		var _path = _mods[? _key].path + _folder
		
		if directory_exists(_path) {
			return _path
		}
		
		_key = ds_map_find_next(_mods, _key)
	}
	
	return ""
}