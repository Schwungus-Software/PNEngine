/// @description Create
if is_struct(special) {
	near = special[$ "near"] ?? 0
	far = special[$ "far"] ?? 1
}

arg0 = near
arg1 = far
interp_skip("sarg0")
interp_skip("sarg1")

event_inherited()