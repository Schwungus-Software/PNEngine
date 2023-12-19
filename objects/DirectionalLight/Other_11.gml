/// @description Create
if is_struct(special) {
	nx = special[$ "nx"] ?? 0
	ny = special[$ "ny"] ?? 0
	nz = special[$ "nz"] ?? -1
}

arg0 = nx
arg1 = ny
arg2 = nz

event_inherited()