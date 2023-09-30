#macro MAX_LIGHTS 16

enum LightTypes {
	NONE,
	DIRECTIONAL,
	POINT,
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
	RED,
	GREEN,
	BLUE,
	ALPHA,
	__SIZE,
}