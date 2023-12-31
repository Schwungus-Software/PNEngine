event_inherited()

type = LightTypes.POINT

near = 0
far = 0

// Virtual Functions
update_args = function (_near, _far) {
	near = _near
	far = _far
	arg0 = _near
	arg1 = _far
}