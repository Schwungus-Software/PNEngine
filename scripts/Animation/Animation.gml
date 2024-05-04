enum BoneSpaces {
	PARENT = 1 << 0,
	WORLD = 1 << 1,
	BONE = 1 << 2,
}

function Animation() : Asset() constructor {
	spaces = 0
	duration = 0
	tps = 0
	
	nodes_amount = 0
	bones_amount = 0
	
	parent_frames = undefined
	world_frames = undefined
	bone_frames = undefined
}