/// @description Create
if is_struct(special) {
	near = special[$ "near"] ?? 0
	far = special[$ "far"] ?? 1
}

arg0 = near
arg1 = far

event_inherited()