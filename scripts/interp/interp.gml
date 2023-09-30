function interp(_in, _out, _angle = false, _scope = undefined) {
	static __interp_hash = variable_get_hash("__interp")
	
	_scope ??= self
	
	var _data = struct_get_from_hash(_scope, __interp_hash)
	
	if _data == undefined {
		var _interps = global.interps
		var _id = ds_list_find_index(_interps, undefined)
		
		if _id == -1 {
			_id = ds_list_size(_interps)
		}
		
		_interps[| _id] = instanceof(_scope) == "instance" ? _scope.id : weak_ref_create(_scope)
		_data = []
		struct_set_from_hash(_scope, __interp_hash, _data)
	}
	
	var _in_hash = variable_get_hash(_in)
	var _out_hash = variable_get_hash(_out)
	var _value = struct_get_from_hash(_scope, _in_hash)
	
	struct_set_from_hash(_scope, _out_hash, _value)
	array_push(_data, [_in, _out, _in_hash, _out_hash, _value, _angle])
}