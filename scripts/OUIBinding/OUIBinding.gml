function OUIBinding(_name, _verb) : OUIElement(_name, undefined, false) constructor {
	verb = _verb
	binding = input_binding_get(_verb)
}