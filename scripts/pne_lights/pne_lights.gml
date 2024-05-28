#macro MAX_LIGHTS 16

enum LightTypes {
	NONE,
	DIRECTIONAL,
	POINT,
	SPOT,
}

enum LightData {
	TYPE,
	ACTIVE,
	X,
	Y,
	Z,
	ARG0,
	ARG1,
	ARG2,
	ARG3,
	ARG4,
	ARG5,
	RED,
	GREEN,
	BLUE,
	ALPHA,
	__SIZE,
}