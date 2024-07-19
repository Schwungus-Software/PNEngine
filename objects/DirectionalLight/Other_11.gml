/// @description Create
if is_struct(special) {
	nx = special[$ "nx"] ?? 0
	ny = special[$ "ny"] ?? 0
	nz = special[$ "nz"] ?? -1
	shadow = special[$ "shadow"] ?? false
}

arg0 = nx
arg1 = ny
arg2 = nz
interp_skip("sarg0")
interp_skip("sarg1")
interp_skip("sarg2")

event_inherited()

if shadow {
	shadow_camera = area.add(Camera)
	
	with shadow_camera {
		f_ortho = true
		output.SetFormat(surface_r32float)
	}
	
	with area {
		if not instance_exists(shadowmap_caster) {
			shadowmap_caster = other.id
		}
	}
}