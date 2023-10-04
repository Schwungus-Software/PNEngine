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
	
	static __force_clear = function () {
		if slot == 0 {
			ds_map_copy(flags, global.default_flags)
		} else {
			ds_map_clear(flags)
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
		
		__force_clear()
		
		return true
	}
}