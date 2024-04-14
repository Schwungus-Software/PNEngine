#macro MAX_LIGHTS 16

enum LightTypes {
	NONE,
	DIRECTIONAL,
	POINT,
}

enum LightData {
	TYPE = 0,
	ACTIVE = buffer_sizeof(buffer_f32),
	X = 2 * buffer_sizeof(buffer_f32),
	Y = 3 * buffer_sizeof(buffer_f32),
	Z = 4 * buffer_sizeof(buffer_f32),
	ARG0 = 5 * buffer_sizeof(buffer_f32),
	ARG1 = 6 * buffer_sizeof(buffer_f32),
	ARG2 = 7 * buffer_sizeof(buffer_f32),
	RED = 8 * buffer_sizeof(buffer_f32),
	GREEN = 9 * buffer_sizeof(buffer_f32),
	BLUE = 10 * buffer_sizeof(buffer_f32),
	ALPHA = 11 * buffer_sizeof(buffer_f32),
	__SIZE = 12 * buffer_sizeof(buffer_f32),
}