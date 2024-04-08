function Flags(_id) constructor {
	slot = _id
	flags = ds_map_create()
	
	static get = function (_key) {
		return flags[? _key]
	}
	
	static set = function (_key, _value) {
		flags[? _key] = _value
		
		return true
	}
	
	static copy = function (_struct) {
		var _names = struct_get_names(_struct)
		var i = 0
		
		repeat struct_names_count(_struct) {
			var _name = _names[i++]
			
			set(_name, _struct[$ _name])
		}
	}
	
	static clear = function () {
		if slot == 0 {
			ds_map_copy(flags, global.default_flags)
		} else {
			ds_map_clear(flags)
		}
		
		return true
	}
}