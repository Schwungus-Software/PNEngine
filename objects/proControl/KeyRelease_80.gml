if global.console {
	exit
}

var _interps = global.interps
var i = 0
var _valid = 0
var _alive = [0, 0]
var _ghost = [0, 0]

repeat ds_list_size(_interps) {
	var _scope = _interps[| i++]
	
	if _scope == undefined {
		continue
	}
	
	++_valid
	
	if is_numeric(_scope) {
		if instance_exists(id) {
			++_alive[0]
		} else {
			++_ghost[0]
		}
	} else {
		if weak_ref_alive(_scope) {
			print(instanceof(_scope.ref));
			++_alive[1]
		} else {
			++_ghost[1]
		}
	}
}

print($"Found {_valid} interps ({_alive} alive, {_ghost} ghosts)")