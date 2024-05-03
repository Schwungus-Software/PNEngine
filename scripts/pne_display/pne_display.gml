#macro COLOR_INVERSE 0.003921568627451 // 1/255
#macro SMOOTH_INVERSE 0.3333333333333333 // 1/3

#region Colors
	#macro C_PN_RED 857048
	#macro C_PN_YELLOW 59387
	#macro C_PN_GREEN 49288
	#macro C_PN_BLUE 15566148
	#macro C_PN_LIGHT_BLUE 15318923

	#macro C_SUN_YELLOW 8454143
	#macro C_NIGHT_BLUE 8405056
	#macro C_FOG_SUNSET 9342369
	#macro C_FOG_NIGHT 7220268
#endregion

#region Display
	application_surface_enable(false)
	application_surface_draw_enable(false)
	surface_free(application_surface)
	display_set_gui_size(480, 270)
#endregion

#region Rendering
	enum Canvases {
		WORLD,
		RENDER,
		__SIZE,
	}
	
	var _canvases = array_create(Canvases.__SIZE)
	
	_canvases[Canvases.WORLD] = new Canvas(480, 270)
	_canvases[Canvases.RENDER] = (new Canvas(480, 270)).SetDepthDisabled(true)
	global.canvases = _canvases
	global.bloom = new Bloom(160, 90, 3)
	gpu_set_ztestenable(true)
	gpu_set_zwriteenable(true)
	global.current_shader = undefined
#endregion

#region Cameras
	global.camera_active = noone
	global.camera_demo = noone
	global.camera_layer = 0
#endregion

#region Vertex Buffers
	vertex_format_begin()
	vertex_format_add_position_3d() // 3 * 4 (f32)
	vertex_format_add_normal() // 3 * 4 (f32)
	vertex_format_add_texcoord() // 2 * 4 (f32)
	vertex_format_add_colour() // 1 * 4 (u8)
	vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord) // 4 * 4 (f32)
	vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord) // 4 * 4 (f32)
	global.vbo_format = vertex_format_end()
#endregion

#region Batch Rendering
	global.batch_vbo = vertex_create_buffer()
	global.batch_matrix = matrix_build_identity()
	global.batch_camera = noone
	
	global.batch_texture = undefined
	global.batch_alpha_test = 0
	global.batch_bright = 0
	global.batch_blendmode = bm_normal
	
	vertex_begin(global.batch_vbo, global.vbo_format)
#endregion

#region Particles
	#macro MAX_PARTICLES 128
	
	enum ParticleAnimations {
		PLAY,
		PLAY_STAY,
		LOOP,
	}
	
	enum ParticleData {
		DEAD,
		IMAGE,
		FRAME,
		FRAME_SPEED,
		ANIMATION,
		ALPHA_TEST,
		WIDTH,
		WIDTH_SPEED,
		HEIGHT,
		HEIGHT_SPEED,
		ANGLE,
		ANGLE_SPEED,
		COLOR,
		ALPHA,
		ALPHA_SPEED,
		BRIGHT,
		BRIGHT_SPEED,
		TICKS,
		X,
		Y,
		Z,
		FLOOR_Z,
		CEILING_Z,
		X_SPEED,
		Y_SPEED,
		Z_SPEED,
		X_FRICTION,
		Y_FRICTION,
		Z_FRICTION,
		GRAVITY,
		MAX_FLY_SPEED,
		MAX_FALL_SPEED,
		__SIZE,
	}
	
	global.dead_particles = ds_stack_create()
#endregion