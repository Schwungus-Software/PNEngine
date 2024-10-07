/// @description Create
var _level_name = level.name

if _level_name != "lvlLogo" and _level_name != "lvlIntro" {
	instance_destroy(self, false)
	
	exit
}

event_inherited()