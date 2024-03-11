// Feather disable all

//This script contains the default profiles, and hence the default bindings and verbs, for your game
//
//  Please edit this macro to meet the needs of your game!
//
//The struct return by this script contains the names of each default profile.
//Default profiles then contain the names of verbs. Each verb should be given a binding that is
//appropriate for the profile. You can create bindings by calling one of the input_binding_*()
//functions, such as input_binding_key() for keyboard keys and input_binding_mouse() for
//mouse buttons

// INPUTPATCH: PNEngine verbs
function __input_config_verbs()
{
    return {
	    keyboard_and_mouse: {
	        up:    input_binding_key("W"),
			left:  input_binding_key("A"),
	        down:  input_binding_key("S"),
	        right: input_binding_key("D"),
			walk: input_binding_key(vk_shift),
        
	        jump:     input_binding_key(vk_space),
	        interact: input_binding_key("E"),
			attack:   [input_binding_key(vk_period), input_binding_mouse_button(mb_left)],
		
			inventory_up:    input_binding_key("1"),
			inventory_left:  input_binding_key("2"),
			inventory_down:  input_binding_key("3"),
			inventory_right: input_binding_key("4"),
        
	        aim:       [input_binding_key(vk_comma), input_binding_mouse_button(mb_right)],
			aim_up:    input_binding_key(vk_up),
			aim_left:  input_binding_key(vk_left),
	        aim_down:  input_binding_key(vk_down),
	        aim_right: input_binding_key(vk_right),
        
			ui_up: input_binding_key(vk_up),
			ui_left: input_binding_key(vk_left),
			ui_down: input_binding_key(vk_down),
			ui_right: input_binding_key(vk_right),
			ui_enter: input_binding_key(vk_enter),
		
	        pause: input_binding_key(vk_escape),
			leave: input_binding_key(vk_backspace),
		
			chat: input_binding_key("T"),
			chat_submit: input_binding_key(vk_enter),
			chat_previous: input_binding_key(vk_up),
			voice: input_binding_key("V"),
		
			debug_overlay: input_binding_key(vk_f1),
			debug_console: input_binding_key(192),
			debug_console_submit: input_binding_key(vk_enter),
			debug_console_previous: input_binding_key(vk_up),
	    },
    
	    gamepad: {
	        up:    input_binding_gamepad_axis(gp_axislv, true),
			left:  input_binding_gamepad_axis(gp_axislh, true),
	        down:  input_binding_gamepad_axis(gp_axislv, false),
	        right: input_binding_gamepad_axis(gp_axislh, false),
        
	        jump:     input_binding_gamepad_button(gp_face1),
	        interact: input_binding_gamepad_button(gp_face2),
			attack:   input_binding_gamepad_button(gp_shoulderrb),
		
			inventory_up:    input_binding_gamepad_button(gp_padu),
	        inventory_left:  input_binding_gamepad_button(gp_padl),
			inventory_down:  input_binding_gamepad_button(gp_padd),
			inventory_right: input_binding_gamepad_button(gp_padr),
        
			aim:       input_binding_gamepad_button(gp_shoulderlb),
	        aim_up:    input_binding_gamepad_axis(gp_axisrv, true),
			aim_left:  input_binding_gamepad_axis(gp_axisrh, true),
	        aim_down:  input_binding_gamepad_axis(gp_axisrv, false),
	        aim_right: input_binding_gamepad_axis(gp_axisrh, false),
        
			ui_up:    input_binding_gamepad_button(gp_padu),
	        ui_left:  input_binding_gamepad_button(gp_padl),
			ui_down:  input_binding_gamepad_button(gp_padd),
			ui_right: input_binding_gamepad_button(gp_padr),
			ui_enter: input_binding_gamepad_button(gp_face1),
		
	        pause: input_binding_gamepad_button(gp_start),
			leave: input_binding_gamepad_button(gp_select),
	    },
    
	    touch: {},
	};
}