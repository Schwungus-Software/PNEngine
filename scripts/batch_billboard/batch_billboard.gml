/// @desc Adds a X/Y billboard image that faces the camera to the batch.
function batch_billboard(_image, _frame, _width, _height, _x, _y, _z, _angle = 0, _color = c_white, _alpha = 1) {
	var _camera = global.batch_camera
	
	if not instance_exists(_camera) {
		return false
	}
	
	var _texture = _image.GetTexture(_frame)
	
	if _texture != global.batch_texture {
		batch_submit()
		global.batch_texture = _texture
	}
	
	var _x_offset = (_image.GetXOffset() / _image.GetWidth()) * _width
	var _y_offset = (_image.GetYOffset() / _image.GetHeight()) * _height
	
	var _yaw = _camera.yaw + 180
	var _pitch = -_camera.pitch
	
	var _matrix = matrix_multiply(
		matrix_multiply(
			matrix_build(0, (_width * -0.5) + _x_offset, (_height * -0.5) + _y_offset, 0, 0, 0, _width, _width, _height),
			matrix_build(0, 0, 0, _angle, 0, 0, 1, 1, 1)
		),
		
		matrix_build(_x, _y, _z, 0, _pitch, _yaw, 1, 1, 1)
	)
	
	var _vert1 = matrix_transform_point(_matrix, 0, -0.5, 0.5)
	var _x1 = _vert1[0]
	var _y1 = _vert1[1]
	var _z1 = _vert1[2]
	
	var _vert2 = matrix_transform_point(_matrix, 0, -0.5, -0.5)
	var _x2 = _vert2[0]
	var _y2 = _vert2[1]
	var _z2 = _vert2[2]
	
	var _vert3 = matrix_transform_point(_matrix, 0, 0.5, -0.5)
	var _x3 = _vert3[0]
	var _y3 = _vert3[1]
	var _z3 = _vert3[2]
	
	var _vert4 = matrix_transform_point(_matrix, 0, 0.5, 0.5)
	var _x4 = _vert4[0]
	var _y4 = _vert4[1]
	var _z4 = _vert4[2]
	
	var _pitch_factor = dcos(_pitch)
	var _nx = dcos(_yaw) * _pitch_factor
	var _ny = -dsin(_yaw) * _pitch_factor
	var _nz = dsin(_pitch)
	
	var _uvs = _image.GetUVs(_frame)
	var _u1 = _uvs.normLeft
	var _v1 = _uvs.normTop
	var _u2 = _u1 + _uvs.normRight
	var _v2 = _v1 + _uvs.normBottom
	
	var _batch_vbo = global.batch_vbo
	
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, _nx, _ny, _nz, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x2, _y2, _z2, _nx, _ny, _nz, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, _nx, _ny, _nz, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, _nx, _ny, _nz, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, _nx, _ny, _nz, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x4, _y4, _z4, _nx, _ny, _nz, _u1, _v1, _color, _alpha)
	
	return true
}