#macro _32_LIMIT 4294967296
#macro _32_MAX 4294967295

#macro DEFAULT_RNG_LEFT 4
#macro DEFAULT_RNG_RIGHT 29

function RNG() constructor {
	left = DEFAULT_RNG_LEFT
	right = DEFAULT_RNG_RIGHT
	
	static next = function () {
		right = ((36969 * (right & 65535) + (right >> 16))) % _32_LIMIT
		left = (18000 * (left & 65535) + (left >> 16)) % _32_LIMIT
		
		return ((right << 16) + left) % _32_LIMIT
	}
	
	static int = function (_x = 1) {
		gml_pragma("forceinline")
		
		return round((next() / _32_MAX) * _x)
	}
	
	static int_range = function (_x, _y) {
		gml_pragma("forceinline")
		
		return round(lerp(_x, _y, next() / _32_MAX))
	}
	
	static int_sign = function (_x = 1) {
		gml_pragma("forceinline")
		
		return int_range(-_x, _x)
	}
	
	static float = function (_x = 1) {
		gml_pragma("forceinline")
		
		return (next() / _32_MAX) * _x
	}
	
	static float_range = function (_x, _y) {
		gml_pragma("forceinline")
		
		return lerp(_x, _y, next() / _32_MAX)
	}
	
	static float_sign = function (_x = 1) {
		gml_pragma("forceinline")
		
		return float_range(-_x, _x)
	}
	
	static pick = function () {
		gml_pragma("forceinline")
		
		var _argc = argument_count
		
		if _argc != 0 {
			return argument[int(_argc - 1)]
		}
		
		return undefined
	}
}

global.rng_game = new RNG()
global.rng_visual = new RNG()