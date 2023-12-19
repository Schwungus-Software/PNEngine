/// @description Create
event_inherited()

if not is_struct(special) {
	print("! Sky.create: Special properties invalid or not found")
	destroy()
	
	exit
}

material = global.materials.get(special[$ "material"])
mdlSky = global.models.get("mdlSky")

if mdlSky != undefined {
	mdlSky.submodels[0].materials[0] = material
	model = new ModelInstance(mdlSky)
}

area.sky = id