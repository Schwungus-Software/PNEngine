/// @description Create
if is_struct(special) {
	nx = force_type_fallback(special[$ "nx"], "number", 0)
	ny = force_type_fallback(special[$ "ny"], "number", 0)
	nz = force_type_fallback(special[$ "nz"], "number", 1)
}

arg0 = nx
arg1 = ny
arg2 = nz
interp_skip("sarg0")
interp_skip("sarg1")
interp_skip("sarg2")

event_inherited()