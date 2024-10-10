event_inherited()

type = LightTypes.DIRECTIONAL
active = 1

nx = 0
ny = 0
nz = -1

// Virtual Functions
update_args = function (_nx, _ny, _nz) {
	nx = _nx
	ny = _ny
	nz = _nz
	arg0 = _nx
	arg1 = _ny
	arg2 = _nz
}