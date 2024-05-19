function screenshot_canvas() {
	var _width = window_get_width()
	var _height = window_get_height()
	var _canvas = new Canvas(_width, _height)
	
	_canvas.Start()
	draw_clear(c_black)
	
	var _players = global.players
	var _camera_active = global.camera_active
	
	if instance_exists(_camera_active) {
		_camera_active.render(_width, _height, true).Draw(0, 0)
	} else {
		var _camera_demo = global.camera_demo
		
		if instance_exists(_camera_demo) {
			_camera_demo.render(_width, _height, true).Draw(0, 0)
		} else {
			switch global.players_active {
				case 1:
					var i = 0
				
					repeat INPUT_MAX_PLAYERS {
						with _players[i++] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height, true).Draw(0, 0)
							
								break
							}
						}
					}
				break
			
				case 2:
					_height *= 0.5
					
					var _y = 0
					var i = 0
				
					repeat INPUT_MAX_PLAYERS {
						with _players[i] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height, i == 0).Draw(0, _y)
							}
						}
						
						_y += _height;
						++i
					}
				break
			
				case 3:
				case 4:
					_width *= 0.5
					_height *= 0.5
					
					var _x = 0
					var _y = 0
					var i = 0
				
					repeat INPUT_MAX_PLAYERS {
						with _players[i] {
							if status == PlayerStatus.ACTIVE and instance_exists(camera) {
								camera.render(_width, _height, i == 0).Draw(_x, _y)
							}
						}
						
						_x += _width
						
						if _x > _width {
							_x = 0
							_y += _height
						}
						
						++i
					}
				break
			}
		}
	}
	
	_canvas.Finish()
	
	return _canvas
}