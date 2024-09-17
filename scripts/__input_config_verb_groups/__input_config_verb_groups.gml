// Feather disable all

//Defines which verbs should collide with which other verbs when using input_binding_get_collisions()
//and input_binding_set_safe(). A verb that is not present in a group will collide with all other verbs
//
//__input_config_verb_groups() must be defined using the following format:
//
//return {
//    <group name>: [<verb1>, <verb2>, ...],
//    <group name>: [<verb3>, <verb4>, ...],
//    ...
//}

function __input_config_verb_groups()
{
    return {
        game: [
			"up", "left", "down", "right", "walk",
			"jump", "interact", "attack",
			"inventory_up", "inventory_left", "inventory_down", "inventory_right",
			"aim", "aim_up", "aim_left", "aim_down", "aim_right",
		],
		
		ui: [
			"ui_up", "ui_left", "ui_down", "ui_right",
			"ui_enter",
			"pause", "leave",
		],
		
		debug: [
			"debug_overlay", "debug_fps",
			"debug_console", "debug_console_submit", "debug_console_previous",
		],
    };
}