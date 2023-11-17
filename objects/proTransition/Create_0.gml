transition_script = undefined

create = undefined
clean_up = undefined
tick = undefined
draw_gui = undefined

state = 0
to_level = undefined
to_area = 0
to_tag = noone

#region Functions
	is_ancestor = function (_type) {
		if is_string(_type) {
			if transition_script != undefined {
				return transition_script.is_ancestor(_type)
			}
			
			_type = asset_get_index(_type)
			
			if not object_exists(_type) {
				return false
			}
		}
		
		return object_index == _type or object_is_ancestor(object_index, _type)
	}
	
	destroy = function () {
		instance_destroy()
	}
#endregion