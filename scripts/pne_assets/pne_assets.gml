global.mods = ds_map_create()

var _disabled_mods = json_load("data/disabled.json")

if not is_array(_disabled_mods) {
	_disabled_mods = []
}

var n = array_length(_disabled_mods)
var _load_mods = []
var _mod = file_find_first("data/*", fa_directory)

while _mod != "" {
	if directory_exists("data/" + _mod) {
		var _enabled = true
		var i = 0
		
		repeat n {
			if _disabled_mods[i++] == _mod {
				print($"! pne_assets: Mod '{_mod}' is disabled, skipping")
				_enabled = false
				
				break
			}
		}
		
		if _enabled {
			array_push(_load_mods, _mod)
		}
	}
	
	_mod = file_find_next()
}

file_find_close()

array_foreach(_load_mods, function (_element, _index) {
	var _mod = new Mod(_element)
})