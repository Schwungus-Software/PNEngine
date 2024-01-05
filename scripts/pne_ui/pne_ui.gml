enum UIInputs {
	UP_DOWN,
	LEFT_RIGHT,
	CONFIRM,
	BACK,
	__SIZE,
}

global.ui = undefined
global.ui_input = array_create(UIInputs.__SIZE)