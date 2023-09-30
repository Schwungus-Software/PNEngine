/// @description Create
material = global.materials.get(special[$ "material"])
mdlSky = global.models.get("mdlSky")

if mdlSky != undefined {
	mdlSky.submodels[0].materials[0] = material
	model = new ModelInstance(mdlSky)
}

area.sky = id

event_inherited()