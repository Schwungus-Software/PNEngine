function mod_find_file(_filename, _exclude = "") {
	var _mods = global.mods
	var _key = ds_map_find_last(_mods)
	
	repeat ds_map_size(_mods) {
		var _path = _mods[? _key].path
		var _target = file_find_first(_path + _filename, fa_none)
		
		while _target != "" {
			if filename_ext(_target) == _exclude {
				_target = file_find_next()
				
				continue
			}
			
			file_find_close()
			
			return _path + filename_path(_filename) + _target
		}
		
		file_find_close()
		_key = ds_map_find_previous(_mods, _key)
	}
	
	return ""
}