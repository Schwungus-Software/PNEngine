// input-string library feather disable all

function input_string_async_get(_prompt, _string = undefined)
{
    _string = _string ?? (__input_string()).__value;
    
    with (__input_string())
    {
        if (__async_id != undefined)
        {
            // Do not request the input modal when it is already open
            show_debug_message("Input String Warning: Dialog prompt refused. Awaiting callback ID \"" + string(__async_id) + "\"");
            return false;
        }
        else
        {
            // Note platform suitability
            var _source = input_string_platform_hint();
            if (_source != "async")    show_debug_message("Input String Warning: Async dialog is not suitable for use on the current platform");
            if (_source == "virtual")  show_debug_message("Input String Warning: Consider showing the virtual keyboard for non-modal text input instead");
            
            if ((os_type == os_android) || (os_type == os_ios) || (os_type == os_tvos))
            {
                // Hide lingering overlay on dialog prompt open (Fixes mobile keyboard focus quirk)
                keyboard_virtual_hide();
            }
            
            if (_string != "")
            {
                var _console_limit = 0;
                switch(os_type)
                {
                    // Enforce dialog character limit per platform
                    case os_xboxone: case os_xboxseriesxs: _console_limit =  256; break;
                    case os_switch:                        _console_limit =  500; break;
                    case os_ps4: case os_ps5:              _console_limit = 1024; break;
                }
                
                if (_console_limit > 0)
                {
                    show_debug_message("Input String Warning: Platform dialog has a limit of " + string(_console_limit) + " characters");
                    _string = string_copy(_string, 1, _console_limit);
                }
                
                if (string_length(_string) > max_length)
                {
                    // Enforce configured character limit
                    show_debug_message("Input String Warning: Truncating string to " + string(max_length) + " characters");
                    _string = string_copy(_string, 1, max_length);
                }
            }
        
            __predialog = input_string_get();
            __async_id  = get_string_async(_prompt, _string);
        
            return true;
        }
    }
}

// input-string feather disable all

function input_string_dialog_async_event()
{
    if (string_pos("__YYInternalObject__", object_get_name(object_index)) > 0)
    {
        // Object event only
        show_error("Input String Error: Async dialog used in invalid context (outside an object async event)", true);
    }
    
    if (event_number != ((os_browser == browser_not_a_browser)? ev_dialog_async : 0))
    {
        // Async dialog event only
        show_error
        (
            "Input String Error: Async dialog used in invalid event " 
                + object_get_name(object_index) + ", " 
                + "Event " + string(event_type) + ", " 
                + "no. " + string(event_number) + ") ",
            true
        );
        
        return;
    }
    
    with (__input_string())
    {
        if (input_string_async_active() && (async_load != -1) && (async_load[? "id"] == __async_id))
        {                
            // Confirm Async
            var _result = async_load[? "result"];
            if ((async_load[? "status"] != true) || (_result == undefined))
            {
                // Set empty
                _result = "";
            }
            else
            {
                _result = string(_result);
            }
                
            if ((async_load[? "status"] != true) || (!allow_empty && (_result == "")))
            {
                // Revert empty
                _result = __predialog;
            }
            else
            {
                __async_submit = true;
            }
            
            __set(_result);
            __async_id = undefined;
            
            if (__async_submit) __submit();
        }
    }
}

function input_string_async_active()
{
    return ((__input_string()).__async_id != undefined);
}