function FontMap() : AssetMap() constructor {
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "fonts/" + _name
		var _font_file = mod_find_file(_path + ".ttf")
		
		if _font_file == "" {
			_font_file = mod_find_file(_path + ".png")
		}
		
		if _font_file == "" {
			print("! FontMap.load: '{0}' not found", _name)
		} else {
			if filename_ext(_font_file) == ".ttf" {
				// True Typeface Font (unstable)
				var _size = 8
				var _bold = false
				var _italics = false
				var _first = 32
				var _last = 128
				var _sdf = false
				var _sdf_spread = 8
				
				var _json = json_load(mod_find_file(_path + ".json"))
				
				if is_struct(_json) {
					_size = _json[$ "size"] ?? 8
					_bold = _json[$ "bold"] ?? false
					_italics = _json[$ "italics"] ?? false
					_first = _json[$ "first"] ?? 32
					_last = _json[$ "last"] ?? 128
					_sdf = _json[$ "sdf"] ?? false
					_sdf_spread = _json[$ "sdf_spread"] ?? 8
				}
				
				var _font = new Font()
				var _font_id = font_add(_font_file, _size, _bold, _italics, _first, _last)
				var _font_name = font_get_name(_font_id)
				
				// TODO: Forcefully shove TTF fonts down Scribble's throat
				//		 without crashing it.
				
				if _sdf {
					font_enable_sdf(_font_id, true)
					font_sdf_spread(_font_id, _sdf_spread)
				}
				
				with _font {
					name = _name
					font = _font_id
				}
			} else {
				// Sprite Font
				var _sprite
				var _frames = 1
				var _proportional = true
				var _space = 1
				
				var _json = json_load(mod_find_file(_path + ".json"))
				
				if is_struct(_json) {
					_frames = _json[$ "frames"] ?? 1
					_proportional = _json[$ "proportional"] ?? true
					_space = _json[$ "space"] ?? 1
				}
				
				_sprite = sprite_add(_font_file, _frames, false, false, 0, 0)
				sprite_collision_mask(_sprite, true, 0, 0, 0, 0, 0, bboxkind_precise, 255)
				
				var _font = new Font()
				var _font_id = font_add_sprite(_sprite, 32, _proportional, _space)
				var _font_name = font_get_name(_font_id)
				
				scribble_font_rename(_font_name, _name)
				
				with _font {
					name = _name
					sprite = _sprite
					font = _font_id
				}
			}
		
			ds_map_add(assets, _name, _font)
			print("FontMap.load: Added '{0}' ({1})", _name, _font)
		}
	}
}

global.fonts = new FontMap()