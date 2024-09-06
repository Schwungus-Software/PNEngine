/// @description Create
if is_struct(special) {
	nx = special[$ "nx"] ?? 0
	ny = special[$ "ny"] ?? 0
	nz = special[$ "nz"] ?? -1
}

arg0 = nx
arg1 = ny
arg2 = nz
interp_skip("sarg0")
interp_skip("sarg1")
interp_skip("sarg2")

event_inherited()