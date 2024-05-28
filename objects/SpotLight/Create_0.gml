event_inherited()

type = LightTypes.SPOT

nx = 1
ny = 0
nz = 0
range = 1
cutoff_inner = 0
cutoff_outer = 1

// Virtual Functions
update_args = function (_nx, _ny, _nz, _range, _cutoff_inner, _cutoff_outer) {
	nx = _nx
	ny = _ny
	nz = _nz
	range = _range
	cutoff_inner = _cutoff_inner
	cutoff_outer = _cutoff_outer
	
	arg0 = _nx
	arg1 = _ny
	arg2 = _nz
	arg3 = _range
	arg4 = _cutoff_inner
	arg5 = _cutoff_outer
}