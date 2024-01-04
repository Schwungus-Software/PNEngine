function flags_force_copy(_scope, _struct){
	var _flags = _scope.flags
	var _names = struct_get_names(_struct)
	var i = 0
	
	repeat struct_names_count(_struct) {
		var _name = _names[i++]
		
		_flags[? _name] = _struct[$ _name]
	}
}