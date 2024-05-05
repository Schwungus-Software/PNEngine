/// @description Tick
event_inherited()

if poi_target != ThingTags.NONE {
	var _targets = area.find_tag(poi_target)
	var i = 0
	
	repeat array_length(_targets) {
		var _target = _targets[i++]
		
		if not ds_map_exists(pois, _target) {
			add_poi(_target, poi_lerp, 0, 0, _target.height * -0.5)
		}
	}
}