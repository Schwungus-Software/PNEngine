/// @description Load
if not is_struct(special) {
	print("! Sky.load: Special properties invalid or not found")
	
	exit
}

var _material = special[$ "material"]

if is_string(_material) {
	var _materials = global.materials
	
	_materials.load(_material, true)
	_material = _materials.get(_material) 
	
	if _material != undefined {
		global.models.load("mdlSky")
	}
}