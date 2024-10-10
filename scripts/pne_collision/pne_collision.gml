#macro COLLIDER_REGION_SIZE 128
#macro COLLIDER_REGION_SIZE_INVERSE 0.0078125
#macro COLLIDER_REGION_RADIUS 64

enum TriangleData {
	X1,
	Y1,
	Z1,
	X2,
	Y2,
	Z2,
	X3,
	Y3,
	Z3,
	NX,
	NY,
	NZ,
	SURFACE,
	FLAGS,
	LAYERS,
	__SIZE,
}

enum CollisionFlags {
	BODY = 1 << 0,
	BULLET = 1 << 1,
	VISION = 1 << 2,
	CAMERA = 1 << 3,
	SHADOW = 1 << 4,
	STICKY = 1 << 5,
	SLIPPERY = 1 << 6,
	BUMP = 1 << 7,
	ALL = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7),
}

enum CollisionLayers {
	_0 = 1 << 0,
	_1 = 1 << 1,
	_2 = 1 << 2,
	_3 = 1 << 3,
	_4 = 1 << 4,
	_5 = 1 << 5,
	_6 = 1 << 6,
	_7 = 1 << 7,
	ALL = 0xFF,
}

enum RaycastData {
	HIT,
	X,
	Y,
	Z,
	NX,
	NY,
	NZ,
	SURFACE,
	THING,
	TRIANGLE,
	__SIZE,
}