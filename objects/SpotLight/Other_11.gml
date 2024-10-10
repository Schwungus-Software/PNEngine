/// @description Create
if is_struct(special) {
	nx = force_type_fallback(special[$ "nx"], "number", 1)
	ny = force_type_fallback(special[$ "ny"], "number", 0)
	nz = force_type_fallback(special[$ "nz"], "number", 0)
	range = force_type_fallback(special[$ "range"], "number", 1)
	cutoff_inner = force_type_fallback(special[$ "cutoff_inner"], "number", 0)
	cutoff_outer = force_type_fallback(special[$ "cutoff_outer"], "number", 1)
}

arg0 = nx
arg1 = ny
arg2 = nz
arg3 = range
arg4 = cutoff_inner
arg5 = cutoff_outer
interp_skip("sarg0")
interp_skip("sarg1")
interp_skip("sarg2")
interp_skip("sarg3")
interp_skip("sarg4")
interp_skip("sarg5")

event_inherited()