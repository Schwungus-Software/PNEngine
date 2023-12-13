function ImageMap() : AssetMap() constructor {
	ds_map_destroy(assets)
	assets = new Collage()
	
	static start_batch = function () {
		gml_pragma("forceinline")
		
		assets.StartBatch()
	}
	
	static end_batch = function () {
		gml_pragma("forceinline")
		
		assets.FinishBatch()
	}
	
	static load = function (_name) {
		if CollageImageExists(_name) {
			exit
		}
		
		var _path = "images/" + _name
		var _frames = 1
		var _x_offset = 0
		var _y_offset = 0
		var _x_repeat = true
		var _y_repeat = true
		var _json = json_load(mod_find_file(_path + ".json"))
		
		if is_struct(_json) {
			_frames = _json[$ "frames"] ?? 1
			_x_offset = _json[$ "x_offset"] ?? 0
			_y_offset = _json[$ "y_offset"] ?? 0
			_x_repeat = _json[$ "x_repeat"] ?? true
			_y_repeat = _json[$ "y_repeat"] ?? true
		}
		
		var _png_file = mod_find_file(_path + ".png")
		
		if _png_file != "" {
			assets.AddFile(_png_file, _name, _frames, false, false, _x_offset, _y_offset).SetTiling(_x_repeat, _y_repeat)
		} else {
			print($"! ImageMap.load: '{_name}' not found")
		}
	}
	
	static get = function (_name) {
		gml_pragma("forceinline")
		
		return CollageImageExists(_name) ? CollageImageGetInfo(_name) : undefined
	}
	
	static clear = function () {
		gml_pragma("forceinline")
		
		assets.Clear()
	}
}

global.images = new ImageMap()