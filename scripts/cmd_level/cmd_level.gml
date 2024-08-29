function cmd_level(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: level <name> [area] [tag]")
		
		exit
	}
	
	CMD_NO_DEMO
	
	var _level = _parse_args[0]
	
	if mod_find_file("levels/" + _level + ".*") == "" {
		print($"! cmd_level: '{_level}' not found")
		
		exit
	}
	
	var _area = n >= 2 ? real(_parse_args[1]) : 0
	var _tag = n >= 3 ? real(_parse_args[2]) : ThingTags.NONE
	
	global.level.goto(_level, _area, _tag)
}