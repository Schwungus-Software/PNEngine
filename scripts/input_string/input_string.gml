// input-string library feather disable all

function __input_string()
{
    // Self initialize
    static instance = new (function() constructor {
    
        
    #region Configuration
    
    auto_closevkb = true;   // Whether the 'Return' key closes the virtual keyboard
    auto_submit   = true;   // Whether the 'Return' key fires a submission callback
    auto_search   = false;   // Whether to search on any change instead of on demand
    auto_trim     = true;   // Whether submit trims leading and trailing whitespace
    
    allow_empty   = false;  // Whether a blank field submission is treated as valid
    allow_newline = false;  // Whether to allow newline characters or swap to space
    search_case   = false;  // Whether searches are performed with case sensitivity
    
    max_length = 1000;      // Maximum text entry string length. Do not exceed 1024
    
    #endregion
    
    
    #region Initialization
    
    __value     = "";
    __searched  = "";
    __predialog = "";

    __search_list = [];
    __result_list = [];
    
    __backspace_hold_duration  = 0;
    __tick_last                = 0;    
    
    __callback  = undefined;
    __async_id  = undefined;
    
    __use_steam       = false;
    __use_trim        = false;
    __virtual_submit  = false;
    __async_submit    = false;
    __just_ticked     = false;
    __just_set        = false;
    
    __keyboard_supported = ((os_type == os_operagx) || (os_browser != browser_not_a_browser)
                         || (os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)
                         || (os_type == os_android) || (os_type == os_switch) || (os_type == os_tvos) || (os_type == os_ios));
        
    // Feature detect
    try
    {
        // Try Steam setup
        steam_dismiss_floating_gamepad_text_input();
        __use_steam = true;
        show_debug_message("Input String: Using Steamworks extension");
    }
    catch(_error)
    {
        // In absence of Steam extension
        show_debug_message("Input String: Not using Steamworks extension");
    }
    
    try
    {
        var _z = string_trim(" z ");
        __use_trim = (_z == "z");
    }
    catch(_error)
    {
        //show_debug_message("Input String: Not using native trim");
    }
    
    // Set platform hint
    if ((os_type == os_xboxone) || (os_type == os_xboxseriesxs) 
    ||  (os_type == os_switch)  || (os_type == os_ps4) || (os_type == os_ps5))
    {
        // Suggest 'async' (dialog) on console
        __platform_hint = "async";
    }
    else if ((os_browser != browser_not_a_browser)
         &&  ((os_type != os_windows) && (os_type != os_macosx) 
         &&   (os_type != os_operagx) && (os_type != os_linux)))
    {
        // Suggest 'async' (dialog) on non-desktop web
        __platform_hint = "async";
    }
    else if ((os_type == os_android) || (os_type == os_ios) || (os_type == os_tvos))
    {
        // Suggest virtual keyboard on mobile
        __platform_hint = "virtual";
    }
    else
    {
        __platform_hint = "keyboard";
    }
    
    #endregion
    
    
    #region Utilities    
        
    __trim = function(_string)
    {
        if (__use_trim) return string_trim(_string);
        
        var _char  = 0;
        var _right = string_length(_string);
        var _left  = 1;
        
        repeat (_right)
        {
            // Offset left
            _char = ord(string_char_at(_string, _left));
            if ((_char > 8) && (_char < 14) || (_char == 32)) _left++; else break;
        }
        
        repeat (_right - _left)
        {
            // Offset right
            _char = ord(string_char_at(_string, _right));
            if ((_char > 8) && (_char < 14) || (_char == 32)) _right--; else break;
        }
        
        return string_copy(_string, _left, _right - _left + 1);
    };
    
    
    __set = function(_string)
    {
        _string = string(_string);
        
        if (!allow_newline)
        {
            if (os_type != os_windows)
            {
                // Filter carriage returns
                _string = string_replace_all(_string, chr(13), "");
            }
            
            if ((os_type == os_ios) || (os_type == os_tvos))
            {
                // Filter newlines
                _string = string_replace_all(_string, chr(10), " ");
            }
        }
        
        if (string_pos(chr(127), _string) > 0)
        {
            // Filter delete character (fixes Windows and Mac quirk)
            _string = string_replace_all(_string, chr(127), "");
        }
        
        // Enforce length
        var _max = max_length + ((os_type == os_android)? 1 : 0);
        _string = string_copy(_string, 1, _max);
        
        // Left pad one space (fixes Android quirk on first character)
        var _trim = (string_char_at(_string, 1) == " ");
        if ((os_type == os_android) && !_trim)
        {
            // Set leading space
            _string = " " + _string;
            _trim = true;
        }
        
        //Update internal value
        if ((keyboard_string != _string) 
        && ((__tick_last > (current_time - (delta_time div 1000) - 2)) || __just_ticked))
        {
            if (((os_type == os_ios) || (os_type == os_tvos))
            &&  (string_length(keyboard_string) > _max))
            {
                // Close keyboard on overflow (fixes iOS string setting quirk)
                keyboard_virtual_hide();
            }
            
            // Set inbuilt value if necessary
            keyboard_string = _string;
        }
        
        __just_ticked = false;
        __value = _string;
        
        if ((os_type == os_android) && _trim)
        {
            //Strip leading space
            __value = string_delete(__value, 1, 1);
        }
        
        if (auto_search && (__searched != __value)) __search();
    };
    
    
    __submit = function()
    {
        if (auto_trim)
        {
            __set(__trim(input_string_get()));
        }
        
        if ((__callback != undefined) 
        && ((input_string_get() != "") || allow_empty))
        {
            if (is_method(__callback))
            {
                __callback();
            }
            else if (is_numeric(__callback) && script_exists(__callback))
            {
                script_execute(__callback);
            }
            else
            {
                show_error("Input String Error: Callback set to an illegal value (typeof=" + typeof(__callback) + ")", false);
            }
        }
    };
    
    
    __search = function()
    {
        // Clear
        array_delete(__result_list, 0, array_length(__result_list));
        
        // Trim
        if (__trim(__value) == "") return ;
        
        // Set case
        var _find = __value;
        if (!search_case) _find = string_lower(_find);
    
        // Find results
        var _i = 0;
        repeat(array_length(__search_list))
        {
            if (string_pos(_find, __search_list[_i]) > 0) array_push(__result_list, __search_list[_i]);
            ++_i;
        }
        
        __searched = __value;
    };
    
    
    __search_set = function(_array)
    {        
        // Clear
        var _was_empty = (array_length(__search_list) == 0);
        array_delete(__search_list, 0, array_length(__search_list));
        
        // Coallesce
        _array = _array ?? [];
        
        if (!is_array(_array))
        {
            // Stringify
            _array = string(_array);
            
            // Case
            if (!search_case) _array = string_lower(_array);
            
            // Wrap
            __search_list = [_array];
        }
        else
        {
            // Stringify
            if (search_case)
            {
                // Case unchanged
                var _i = 0;
                repeat(array_length(_array))
                {
                    __search_list[_i] = string( _array[_i]);
                    ++_i;
                }
            }
            else
            {
                // Case flattened
                var _i = 0;
                repeat(array_length(_array))
                {
                    __search_list[_i] = string_lower(string( _array[_i] ?? ""));
                    ++_i;
                }
            }
        }
        
        __searched = "";
        if (auto_search && !(_was_empty && (array_length(__search_list) == 0))) __search();
    }
    
    
    __tick = function()
    {
        if (__tick_last <= (current_time - (delta_time div 1000) - 2))
        {
            __just_ticked = true;
            __set(__value);
        }
        
        if (__keyboard_supported && !__just_set && (__async_id == undefined))
        {
            // Manage text input
            var _string = keyboard_string;
            if ((_string == "") && (string_length(__value) > 1))
            {
                // Revert internal string when in overflow state
                _string = "";
            }
            
            __virtual_submit = false;
            if (!input_string_async_active())
            {            
                // Handle virtual keyboard submission
                if ((os_type == os_ios) || (os_type == os_tvos))
                {
                    __virtual_submit = ((ord(keyboard_lastchar) == 10) && (string_length(keyboard_string) > string_length(value)));
                }
                else if ((os_type == os_android) && keyboard_check_pressed(10))
                {
                    __virtual_submit = true;
                }
                else
                {
                    // Keyboard submission
                    __virtual_submit = keyboard_check_pressed(vk_enter);
                }             
            
                if (auto_closevkb && __virtual_submit)
                {
                    // Close virtual keyboard on submission
                    input_string_keyboard_hide();
                }
            }
            
            if (_string != "")
            {
                // Backspace key repeat (fixes lack-of on native Mac and Linux)
                if ((os_browser == browser_not_a_browser) 
                &&  (os_type == os_macosx) || (os_type == os_linux))
                {
                    if (__backspace_hold_duration > 0)
                    {
                        if (keyboard_check_pressed(vk_control) || keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_alt))
                        {
                            keyboard_clear(vk_backspace);
                        }
                        
                        // Repeat on hold, normalized against Windows. Timed in microseconds
                        var _repeat_rate = 33000;
                        if (!keyboard_check(vk_backspace))
                        {
                            __backspace_hold_duration = 0;
                        }
                        else if ((__backspace_hold_duration > 500000)
                             && ((__backspace_hold_duration mod _repeat_rate) > ((__backspace_hold_duration + delta_time) mod _repeat_rate)))
                        {
                            _string = string_copy(_string, 1, string_length(_string) - 1);
                        }
                    }
                    
                    if (keyboard_check(vk_backspace))
                    {
                        __backspace_hold_duration += delta_time;
                    }
                }
            }
            
            __set(_string);
        }
        
        __just_set = false;
                
        if (auto_submit && !__async_submit
        && (__virtual_submit || (__keyboard_supported && keyboard_check_pressed(vk_enter))))
        {
            __submit();
        }
        
        __async_submit = false;
        __tick_last = current_time;
    }
    
    #endregion
    
        
    })(); return instance;
}

function input_string_search_set(_array)
{
    with (__input_string()) __search_set(_array);
}

function input_string_max_length_set(_max_length)
{
    if (!is_numeric(_max_length) || (_max_length < 0) || (_max_length > 1024))
    {
        show_error
        (
            "Input String Error: Invalid value provided for max length: \"" 
                + string(_max_length) 
                + "\". Expected a value between 0 and 1024",
            true
        );

        return;
    }
    
    with (__input_string())
    {
        max_length = _max_length;
        __set(string_copy(__value, 0, _max_length));
    }
}


function input_string_search_results()
{
    with (__input_string())
    {
        if (!auto_search) __search();
        return __result_list;
    }
}

function input_string_callback_set(_callback)
{
    if not (is_undefined(_callback) || is_method(_callback) || (is_numeric(_callback) && !script_exists(_callback)))
    {
        show_error
        (
            "Input String Error: Invalid value provided as callback: \"" 
                + string(_callback) 
                + "\". Expected a function or method.",
            true
        );
        
        return;
    }
    
    with (__input_string()) __callback = _callback;
}

function input_string_set(_string = "")
{
    if ((os_type == os_ios) || (os_type == os_tvos))
    {
        // Close virtual keyboard if string is manually set (fixes iOS setting quirk)
        keyboard_virtual_hide();
    }
    
    with (__input_string())
    {
        __just_set = true;
        __set(_string);
    }
}

function input_string_add(_string)
{
    input_string_set((__input_string()).value + string(_string));
}

function input_string_keyboard_show(_keyboard_type = kbv_type_default)
{
    var _steam = (__input_string()).__use_steam;
    
    // Note platform suitability
    var _source = input_string_platform_hint();
    if ((_source != "virtual") && !_steam) show_debug_message("Input String Warning: Onscreen keyboard is not suitable for use on the current platform");
    if  (_source == "async")               show_debug_message("Input String Warning: Consider using async dialog for modal text input instead");
    
    if ((keyboard_virtual_show != undefined) && script_exists(keyboard_virtual_show) 
    && ((os_type == os_android) || !keyboard_virtual_status()))
    {
        keyboard_virtual_show(_keyboard_type, kbv_returnkey_default, kbv_autocapitalize_sentences, false);
    }
    else if (_steam)
    {
        switch (_keyboard_type)
        {
            case kbv_type_email:   _keyboard_type = steam_floating_gamepad_text_input_mode_email;       break;
            case kbv_type_numbers: _keyboard_type = steam_floating_gamepad_text_input_mode_numeric;     break;
            default:               _keyboard_type = steam_floating_gamepad_text_input_mode_single_line; break;
        }
        
        return steam_show_floating_gamepad_text_input(_keyboard_type, display_get_width(), 0, 0, 0);
    }
    else
    {
         show_debug_message("Input String Warning: Onscreen keyboard not supported on the current platform");
    }
    
    return undefined;
}
   
function input_string_keyboard_hide()
{
    if ((keyboard_virtual_show != undefined) && script_exists(keyboard_virtual_show) 
    && ((os_type == os_android) || keyboard_virtual_status())
    )
    {
        keyboard_virtual_hide();
    }
    else if ((__input_string()).__use_steam)
    {        
        return steam_dismiss_floating_gamepad_text_input();
    }
    
    return undefined;
}

function input_string_platform_hint() { return (__input_string()).__platform_hint;  }
function input_string_force_submit()  { return (__input_string()).__submit();       }
function input_string_submit_get()    { return (__input_string()).__virtual_submit; }
function input_string_tick()          { return (__input_string()).__tick();         }
function input_string_get()           { return (__input_string()).__value;          }