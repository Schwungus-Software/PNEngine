/// @description Create
var _level_name = level.name

if _level_name != "lvlLogo" and _level_name != "lvlIntro" {
	instance_destroy(id, false)
	
	exit
}

event_inherited()