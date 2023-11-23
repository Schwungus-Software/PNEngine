/// @description Create
// Feather ignore GM2016
if level.name != "lvlTitle" {
	instance_destroy(id, false)
	
	exit
}

var _saves = global.saves

ds_list_clear(_saves)

var _name = file_find_first(SAVES_PATH + "*.sav", fa_none)

while _name != "" {
	print($"TitleBase: Found '{_name}'")
	
	var _save = new Save(_name)
	
	ds_list_add(_saves, _save)
	array_push(save_data, new TitleSave(_save))
	_name = file_find_next()
}

file_find_close()

event_inherited()

global.title_start = false
global.save_name = "Debug"