function Flags(_id) constructor {
	slot = _id
	flags = ds_map_create()
	
	static get = function (_key) {
		return flags[? _key]
	}
	
	static set = function (_key, _value) {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active and master {
					var b = net_buffer_create(true, NetHeaders.HOST_FLAG)
					
					buffer_write(b, buffer_u8, other.slot)
					buffer_write(b, buffer_string, _key)
					buffer_write_dynamic(b, _value)
					send(SEND_OTHERS, b)
				} else {
					return false
				}
			}
		}
		
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
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active and master {
					var b = net_buffer_create(true, NetHeaders.HOST_RESET_FLAGS)
					
					buffer_write(b, buffer_u8, other.slot)
					send(SEND_OTHERS, b)
				} else {
					return false
				}
			}
		}
		
		flags_force_clear(self)
		
		return true
	}
}