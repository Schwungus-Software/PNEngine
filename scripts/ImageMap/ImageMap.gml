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
		
		var _mipmap_queue = global.mipmap_queue
		
		if ds_map_exists(_mipmap_queue, _name) {
			exit
		}
		
		var _path = "images/" + _name
		var _frames = 1
		var _x_offset = 0
		var _y_offset = 0
		var _x_repeat = true
		var _y_repeat = true
		var _mipmaps = undefined
		var _json = json_load(mod_find_file(_path + ".json"))
		
		if is_struct(_json) {
			_frames = force_type_fallback(_json[$ "frames"], "number", 1)
			_x_offset = force_type_fallback(_json[$ "x_offset"], "number", 0)
			_y_offset = force_type_fallback(_json[$ "y_offset"], "number", 0)
			_x_repeat = force_type_fallback(_json[$ "x_repeat"], "bool", true)
			_y_repeat = force_type_fallback(_json[$ "y_repeat"], "bool", true)
			_mipmaps = force_type_fallback(_json[$ "mipmaps"], "array")
		}
		
		var _png_file = mod_find_file(_path + ".*", ".json")
		
		if _png_file != "" {
			var _base = assets.AddFile(_png_file, _name, _frames, false, false, _x_offset, _y_offset).SetPremultiplyAlpha(false).SetTiling(_x_repeat, _y_repeat).SetClump(true)
			
			if _base != undefined {
				print($"ImageMap.load: Added '{_name}' to batch")
				
				var _lods = _mipmap_queue[? _name]
				
				if _lods == undefined {
					_lods = [_name]
					_mipmap_queue[? _name] = _lods
				}
				
				if _mipmaps != undefined {
					var i = 0
					
					repeat array_length(_mipmaps) {
						var _lod = force_type(_mipmaps[i++], "string")
						
						if _lod == _name {
							show_error("!!! ImageMap.load: YOU THOUGHT YOU COULD GET AWAY WITH THIS DIDN'T YOU", true)
						}
						
						var _lod_data = load(_lod)
						
						if _lod_data == undefined {
							show_error($"!!! ImageMap.load: Image '{_name}' has invalid LOD '{_lod}'", true)
						}
						
						array_push(_lods, _lod)
					}
				}
			}
			
			return _base
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
global.mipmap_queue = ds_map_create()