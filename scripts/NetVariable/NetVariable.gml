enum NetVarFlags {
	DEFAULT,
	CREATE = 1 << 0,
	TICK = 1 << 1,
	GENERIC = (1 << 0) | (1 << 1),
}

function NetVariable(_name, _flags, _read, _write) constructor {
	slot = noone
	scope = noone
	name = _name
	hash = variable_get_hash(_name)
	value = undefined
	flags = _flags
	read = _read
	write = _write
	
	static update = function (_force = false) {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if not active or not master {
					return false
				}
			}
		} else {
			return false
		}
		
		var b = net_buffer_create(_force, NetHeaders.HOST_THING)
		
		with scope {
			buffer_write(b, buffer_u16, sync_id)
			buffer_write(b, buffer_u32, area.slot)
			buffer_write(b, buffer_string, thing_script != undefined ? thing_script.name : object_get_name(object_index))
		}
		
		buffer_write(b, buffer_u8, 1)
		
		var _value
		
		if write != undefined {
			_value = write(scope)
		} else {
			_value = struct_get_from_hash(scope, hash)
		}
		
		value = _value
		buffer_write(b, buffer_u8, slot)
		buffer_write_dynamic(b, _value)
		_netgame.send(SEND_OTHERS, b)
		
		return true
	}
	
	static set = function (_value, _force = false) {
		var _old = struct_get_from_hash(scope, hash)
		
		struct_set_from_hash(scope, hash, _value)
		
		if not update(_force) {
			struct_set_from_hash(scope, hash, _old)
			
			return false
		}
		
		return true
	}
}