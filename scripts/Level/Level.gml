function Level() constructor {
	name = ""
	areas = ds_map_create()
	
	#region Properties
		rp_name = ""
		rp_icon = ""
		music = undefined
		clear_color = undefined
		ambient_color = undefined
		wind_strength = 1
		wind_direction = undefined
		gravity = 0.6
	#endregion
	
	bump_x = 0
	bump_y = 0
	bump_grid = ds_grid_create(1, 1)
	bump_lists = ds_grid_create(1, 1)
	
	area_things = ds_list_create()
	
	level_script = undefined
	
	start = undefined
	area_changed = undefined
	area_activated = undefined
	area_deactivated = undefined
	
	/// @desc Destroys the contents of the level, allowing it to be removed.
	static destroy = function () {
		ds_list_destroy(area_things)
		
		repeat ds_map_size(areas) {
			var _key = ds_map_find_first(areas)
			
			areas[? _key].destroy()
			ds_map_delete(areas, _key)
		}
		
		ds_map_destroy(areas)
	}
	
	static goto = function (_level, _area = 0, _tag = noone, _transition = noone) {
		with proTransition {
			if state < 3 {
				exit
			}
		}
			
		var _script = undefined
			
		if is_string(_transition) {
			if string_starts_with(_transition, "pro") {
				show_error($"!!! Level.goto: Tried to transition to level using protected Transition '{_transition}'", true)
			}
				
			var _index = asset_get_index(_transition)
				
			if not object_exists(_index) or not object_is_ancestor(_index, proTransition) {
				_script = global.scripts.get(_transition)
					
				if _script != undefined and is_instanceof(_script, TransitionScript) {
					_index = _script.internal_parent
				} else {
					_index = noone
					print($"! Level.goto: Transition '{_transition}' not found")
				}
			}
				
			_transition = _index
		}
			
		if object_exists(_transition) and (_transition == proTransition or object_is_ancestor(_transition, proTransition)) {
			with instance_create_depth(0, 0, 0, _transition) {
				if _script != undefined {
					transition_script = _script
					create = _script.create
					clean_up = _script.clean_up
					tick = _script.tick
					draw_gui = _script.draw_gui
				}
					
				to_level = _level
				to_area = _area
				to_tag = _tag
				event_user(ThingEvents.CREATE)
			}
				
			exit
		}
			
		level_force_goto(_level, _area, _tag, false)
	}
	
	static area_exists = function (_id) {
		gml_pragma("forceinline")
		
		return ds_map_exists(areas, _id)
	}
	
	/// @func count(type)
	/// @desc Returns the amount of the specified Thing and its children in all active areas.
	static count = function (_type) {
		var _count = 0
		var _players = global.players
		var i = 0
		
		repeat INPUT_MAX_PLAYERS {
			var _player = global.players[i++]
			
			if _player.status != PlayerStatus.ACTIVE or _player.level != self {
				continue
			}
			
			var _area = _player.area
			
			if _area != undefined {
				_count += _area.count(_type)
			}
		}
		
		return _count
	}
}