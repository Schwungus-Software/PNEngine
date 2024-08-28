#region Profiling
global.debug_overlay = false
global.debug_fps = false

dbg_view("Resource Counts", false)
global.resource_counts = ""

var _refresh_counts = function () {
	var _info = debug_event("ResourceCounts", true)
	
	var _text = $"DS Lists: {_info.listCount}\n"
	_text += $"DS Maps: {_info.mapCount}\n"
	_text += $"DS Queues: {_info.queueCount}\n"
	_text += $"DS Grids: {_info.gridCount}\n"
	_text += $"DS Priorities: {_info.priorityCount}\n"
	_text += $"DS Stacks: {_info.stackCount}\n"
	_text += $"Buffers: {_info.bufferCount}\n"
	_text += $"Surfaces: {_info.surfaceCount}\n"
	_text += $"Time Sources: {_info.timeSourceCount}\n"
	_text += $"Instances: {instance_count}\n"
	global.resource_counts = _text
}

_refresh_counts()
global.refresh_counts = _refresh_counts
global.refresh_counts_ref = ref_create(global, "refresh_counts")
global.resource_counts_ref = ref_create(global, "resource_counts")
dbg_button("Refresh", global.refresh_counts_ref)
dbg_text(global.resource_counts_ref)
show_debug_overlay(false)
#endregion

#region Console

#macro CMD_NO_NETGAME if net_active() { print("Cannot use this command in a netgame."); exit }
#macro CMD_NO_DEMO if global.demo_buffer != undefined { print("Cannot use this command during demo I/O."); exit }

global.console = false
global.console_buffer = false
	
// Initialize the console log now if anything prior to this script hasn't sent
// any debug messages
if not variable_global_exists("console_log") {
	global.console_log = ds_list_create()
}

global.console_input = ""
global.console_input_previous = ""
#endregion

#region Exception Handling
if os_type != os_linux {
	exception_unhandled_handler(function (e) {
		var exception_json = json_stringify(e, true)
	
	    print("!!! ------------------------------------------------------- !!!")
	    print("Unhandled exception!")
		print(exception_json)
	    print("!!! ------------------------------------------------------- !!!")
	
	    var filename = console_save("crash/crash", "This log was automatically generated by a crash.\n\n" + exception_json)
	
	    if show_question(string(@"PNEngine has crashed.
	A crash log including the details has been saved to {0}.

	The error was:
	{1}

	Do you want to copy the error to the clipboard?", filename, e.longMessage)) {
			clipboard_set_text(exception_json)
			show_message("The error has been copied to the clipboard.")
		}
		
	    return 0
	})
}
#endregion