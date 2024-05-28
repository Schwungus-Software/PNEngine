/// @description Create
if is_struct(special) {
	nx = special[$ "nx"] ?? 1
	ny = special[$ "ny"] ?? 0
	nz = special[$ "nz"] ?? 0
	range = special[$ "range"] ?? 1
	cutoff_inner = special[$ "cutoff_inner"] ?? 0
	cutoff_outer = special[$ "cutoff_outer"] ?? 1
}

arg0 = nx
arg1 = ny
arg2 = nz
arg3 = range
arg4 = cutoff_inner
arg5 = cutoff_outer

event_inherited()