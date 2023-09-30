/// @func json_load(filename)
/// @desc Parses the specified JSON file.
/// @return A struct with the JSON's elements if successful, undefined otherwise.
function json_load(_filename) {
	if not file_exists(_filename) {
		return undefined
	}
	
	var _buffer = buffer_load(_filename)
	var _json = json_parse(buffer_read(_buffer, buffer_text))
	
	buffer_delete(_buffer)
	
	return _json
}