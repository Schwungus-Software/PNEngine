/// @description Create
if is_struct(special) {
	near = force_type_fallback(special[$ "near"], "number", 0)
	far = force_type_fallback(special[$ "far"], "number", 1)
}

arg0 = near
arg1 = far
interp_skip("sarg0")
interp_skip("sarg1")

event_inherited()