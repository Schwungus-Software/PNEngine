/// @description Load
event_inherited()

if not is_struct(special) {
	print("! Prop.load: No model specified")
	
	exit
}

var _model = special[$ "model"]

if not is_string(_model) {
	print($"! Prop.load: Invalid model name '{_model}', expected string")
	
	exit
}

if global.models.fetch(_model) == undefined {
	print($"! Prop.load: Model '{_model}' not found")
}