/// @description Create
event_inherited()

if not is_struct(special) {
	print("! Sky.create: Special properties invalid or not found")
	instance_destroy(id, false)
	
	exit
}

material = global.materials.get(special[$ "material"])
mdlSky = global.models.get("mdlSky")

if mdlSky != undefined {
	mdlSky.submodels[0].materials[0] = material
	model = new ModelInstance(mdlSky)
	
	var _color = color_to_vec5(special[$ "color"])
	
	with model {
		color = _color[4]
		alpha = _color[3]
	}
}

area.sky = id