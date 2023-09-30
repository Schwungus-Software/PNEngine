/// @description Load
var _material = special[$ "material"]

if is_string(_material) {
	var _materials = global.materials
	
	_materials.load(_material, true)
	_material = _materials.get(_material) 
	
	if _material != undefined {
		global.models.load("mdlSky")
	}
}