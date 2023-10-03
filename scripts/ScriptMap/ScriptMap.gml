function ScriptMap() : AssetMap() constructor {
	static load = function (_name, _special = undefined) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "scripts/" + _name
		var _script_file = mod_find_file(_path + ".meow")
		
		if _script_file == "" {
			print($"! ScriptMap.load: '{_name}' not found")
			
			exit
		}
		
		var _script
		
		_script_file = file_text_open_read(_script_file)
		
		var _code = ""
		var _line = ""
		var _lines = 0
		
		try {
			while not file_text_eof(_script_file) {
				_line = file_text_read_string(_script_file)
				file_text_readln(_script_file);
				++_lines
				
				if _lines <= 1 {
					var _header = string_trim_start(string_trim_end(_line))
					
					if string_starts_with(_header, "#thing") {
#region ThingScript
						var _index = asset_get_index(_name)
						
						if object_exists(_index) and object_is_ancestor(_index, Thing) {
							throw "Cannot override internal Thing of the same name"
						}
						
						_script = new ThingScript()
						_script.name = _name
						
						var _parents = string_split(_header, " ", true)
						var _parents_n = array_length(_parents)
						
						if _parents_n >= 2 {
							if _parents_n > 2 {
								throw "Cannot inherit more than one Thing"
							}
							
							var _parent = _parents[1]
							
							load(_parent, _special)
							
							with _script {
								parent = other.get(_parent)
								
								if parent == undefined {
									_index = asset_get_index(_parent)
									
									if not object_exists(_index) {
										throw $"Unknown parent Thing '{_parent}'"
									}
									
									if not object_is_ancestor(_index, Thing) {
										throw $"Cannot inherit non-Thing '{_parent}'"
									}
									
									if string_starts_with(_parent, "pro") {
										throw $"Cannot inherit protected Thing '{_parent}'"
									}
									
									internal_parent = _index
								}
								
								if parent != undefined {
									internal_parent = _parent.internal_parent
									main = _parent.main
									
									load = _parent.load
									create = _parent.create
									on_destroy = _parent.on_destroy
									clean_up = _parent.clean_up
									tick = _parent.tick
									draw = _parent.draw
									draw_screen = _parent.draw_screen
									draw_gui = _parent.draw_gui
								}
								
								thing_load(internal_parent, _special)
							}
						}
#endregion
					} else if string_starts_with(_header, "#level") {
#region Level
						_script = new LevelScript()
						
						var _parents = string_split(_header, " ", true)
						var _parents_n = array_length(_parents)
						
						if _parents_n >= 2 {
							if _parents_n > 2 {
								throw "Cannot inherit more than one LevelScript"
							}
							
							var _parent = _parents[1]
							
							load(_parent)
							
							with _script {
								parent = other.get(_parent)
								
								if parent != undefined {
									main = _parent.main
									load = _parent.load
									start = _parent.start
									area_changed = _parent.area_changed
									area_activated = _parent.area_activated
									area_deactivated = _parent.area_deactivated
								}
							}
						}
#endregion
					} else {
						throw "Script has invalid header"
					}
					
					_line = ""
				}
				
				_code += _line + chr(13) + chr(10)
			}
		} catch (e) {
			show_error($"!!! ScriptMap.load: '{_name}': Error at line {_lines}: {e.longMessage}", true)
		}
		
		file_text_close(_script_file)
		
		var _main = Catspeak.compileGML(Catspeak.parseString(_code))
		
		_main.setSelf(_script)
		
		var _globals = _main.getGlobals()
		var _parent = _script.parent
		
		if _parent != undefined {
			var _parent_globals = _parent.main.getGlobals()
			var _parent_globals_names = struct_get_names(_parent_globals)
			var i = 0
			
			repeat struct_names_count(_parent_globals) {
				var _key = _parent_globals_names[i++]
				
				_globals[$ _key] = _parent_globals[$ _key]
			}
		}
		
		_main()
		
		with _script {
			main = _main
			load = _globals[$ "load"]
			
			if is_instanceof(self, ThingScript) {
				create = _globals[$ "create"]
				on_destroy = _globals[$ "on_destroy"]
				clean_up = _globals[$ "clean_up"]
				tick = _globals[$ "tick"]
				draw = _globals[$ "draw"]
				draw_screen = _globals[$ "draw_screen"]
				draw_gui = _globals[$ "draw_gui"]
			} else if is_instanceof(self, LevelScript) {
				start = _globals[$ "start"]
				area_changed = _globals[$ "area_changed"]
				area_activated = _globals[$ "area_activated"]
				area_deactivated = _globals[$ "area_deactivated"]
			}
			
			if load != undefined {
				load(_special)
			}
		}
		
		ds_map_add(assets, _name, _script)
		print("ScriptMap.load: Added '{0}' ({1})", _name, _script)
	}
	
	static flush = function () {
		var _key = ds_map_find_first(assets)
		
		repeat ds_map_size(assets) {
			assets[? _key].flush()
			_key = ds_map_find_next(assets, _key)
		}
	}
}

global.scripts = new ScriptMap()