#macro _8_BIT_INVERSE 0.003921568627451

enum RNGSeeds {
	GAME,
	VISUAL,
}

function RNG() constructor {
	static table = [
		235, 160, 80, 7, 50, 215, 193, 71, 4, 196, 56, 224, 83, 23, 183, 192, 203,
		107, 65, 41, 158, 93, 157, 114, 244, 5, 77, 127, 154, 118, 248, 86, 230, 155,
		122, 175, 146, 165, 185, 151, 59, 179, 10, 214, 253, 24, 8, 30, 27, 197, 205,
		6, 144, 102, 147, 163, 167, 249, 45, 67, 210, 174, 9, 98, 58, 12, 231, 94,
		217, 164, 139, 39, 22, 187, 62, 140, 159, 105, 143, 206, 0, 178, 29, 181,
		225, 221, 88, 182, 191, 202, 21, 60, 11, 171, 110, 239, 69, 53, 111, 76, 116,
		190, 247, 14, 117, 188, 81, 161, 33, 2, 186, 211, 73, 212, 51, 79, 145, 133,
		209, 25, 119, 168, 78, 226, 103, 16, 222, 49, 92, 134, 149, 198, 13, 19, 120,
		207, 251, 3, 121, 31, 46, 141, 124, 126, 218, 112, 35, 68, 240, 47, 129, 238,
		135, 108, 75, 104, 166, 148, 74, 150, 96, 173, 184, 136, 44, 189, 90, 156,
		204, 85, 40, 137, 38, 232, 152, 236, 70, 162, 63, 242, 201, 216, 220, 18,
		246, 172, 66, 130, 34, 254, 195, 17, 89, 153, 82, 1, 101, 233, 84, 241, 52,
		128, 213, 234, 36, 91, 138, 57, 99, 87, 180, 237, 223, 115, 170, 97, 255, 37,
		42, 95, 15, 199, 219, 123, 132, 43, 125, 131, 200, 169, 61, 250, 64, 113, 55,
		229, 252, 176, 142, 54, 32, 227, 48, 26, 106, 208, 72, 228, 109, 243, 20,
		245, 28, 177, 194, 100,
	]
	
	static indices = []
	
	static float = function (_seed) {
		if _seed >= array_length(indices) {
			indices[_seed] = 0
		}
		
		var _index = indices[_seed]
		var _value = table[_index] * _8_BIT_INVERSE
		
		indices[_seed] = -~_index % 256
		
		return _value
	}
	
	static random = function (_x, _seed = RNGSeeds.GAME) {
		gml_pragma("forceinline")
		
		return float(_seed) * _x
	}
	
	static random_range = function (_x, _y, _seed = RNGSeeds.GAME) {
		gml_pragma("forceinline")
		
		return lerp(_x, _y, float(_seed))
	}
	
	static irandom = function (_x, _seed = RNGSeeds.GAME) {
		gml_pragma("forceinline")
		
		return round(float(_seed) * _x)
	}
	
	static irandom_range = function (_x, _y, _seed = RNGSeeds.GAME) {
		gml_pragma("forceinline")
		
		return round(lerp(_x, _y, float(_seed)))
	}
}

global.rng = new RNG()