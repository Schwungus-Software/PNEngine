/// @feather ignore GM1017
/// @feather ignore GM1019

#region Scripting
	with Catspeak {
		#region Standard Library
			applyPreset(CatspeakPreset.TYPE, CatspeakPreset.ARRAY, CatspeakPreset.STRING, CatspeakPreset.STRUCT)
			
			#region Debug
				addFunction(
					"current_time", function () {
						return current_time
					},
					
					"get_timer", get_timer
				)
			#endregion
			
			#region Math
				addConstant(
					"PI", pi,
					"EPSILON", math_get_epsilon(),
					"RNG", static_get(RNG),
					"RNG_GAME", RNGSeeds.GAME,
					"RNG_VISUAL", RNGSeeds.VISUAL,
				)
				
				addFunction(
			        "round", round,
			        "frac", frac,
			        "abs", abs,
			        "sign", sign,
			        "floor", floor,
			        "ceil", ceil,
			        "min", min,
			        "max", max,
			        "mean", mean,
			        "median", median,
			        "lerp", lerp,
					"lerp_angle", lerp_angle,
					"lerp_smooth", lerp_smooth,
					"lerp_delta", lerp_delta,
			        "clamp", clamp,
			        "exp", exp,
			        "ln", ln,
			        "power", power,
			        "sqr", sqr,
			        "sqrt", sqrt,
			        "log2", log2,
			        "log10", log10,
			        "logn", logn,
			        "arccos", arccos,
			        "arcsin", arcsin,
			        "arctan", arctan,
			        "arctan2", arctan2,
			        "cos", cos,
			        "sin", sin,
			        "tan", tan,
			        "dcos", dcos,
			        "dsin", dsin,
			        "dtan", dtan,
			        "darccos", darccos,
			        "darcsin", darcsin,
			        "darctan", darctan,
			        "darctan2", darctan2,
			        "degtorad", degtorad,
			        "radtodeg", radtodeg,
			        "point_direction", point_direction,
					"point_pitch", point_pitch,
			        "point_distance", point_distance,
			        "dot_product", dot_product,
			        "dot_product_normalized", dot_product_normalized,
			        "angle_difference", angle_difference,
			        "lengthdir_x", lengthdir_x,
			        "lengthdir_y", lengthdir_y
			    )
				
				addFunction(
			        "point_distance_3d", point_distance_3d,
			        "dot_product_3d", dot_product_3d,
			        "dot_product_3d_normalized", dot_product_3d_normalized,
					"cross_product_3d_normalized", cross_product_3d_normalized,
			        "matrix_build", matrix_build,
			        "matrix_multiply", matrix_multiply,
			        "matrix_build_identity", matrix_build_identity,
			        "matrix_build_lookat", matrix_build_lookat,
			        "matrix_build_projection_ortho", matrix_build_projection_ortho,
			        "matrix_build_projection_perspective", matrix_build_projection_perspective,
			        "matrix_build_projection_perspective_fov", matrix_build_projection_perspective_fov,
			        "matrix_transform_point", matrix_transform_point,
					"dq_build", dq_build,
					"dq_build_identity", dq_build_identity,
					"dq_lerp", dq_lerp
			    )
			#endregion
			
			#region Date and Time
				addFunction("date_datetime_string", date_datetime_string)
			#endregion
			
			#region Color
				addConstant(
			        "AQUA", c_aqua,
			        "BLACK", c_black,
			        "BLUE", c_blue,
			        "DARK_GRAY", c_dkgray,
			        "FUCHSIA", c_fuchsia,
			        "GRAY", c_grey,
			        "GREEN", c_green,
			        "LIME", c_lime,
			        "LIGHT_GRAY", c_ltgrey,
			        "MAROON", c_maroon,
			        "NAVY", c_navy,
			        "OLIVE", c_olive,
			        "ORANGE", c_orange,
			        "PURPLE", c_purple,
			        "RED", c_red,
			        "SILVER", c_silver,
			        "TEAL", c_teal,
			        "WHITE", c_white,
			        "YELLOW", c_yellow,
					"PN_RED", C_PN_RED,
					"PN_YELLOW", C_PN_YELLOW,
					"PN_GREEN", C_PN_GREEN,
					"PN_BLUE", C_PN_BLUE,
					"PN_LIGHT_BLUE", C_PN_LIGHT_BLUE
			    )
				
				addFunction(
			        "color_get_blue", color_get_blue,
			        "color_get_green", color_get_green,
			        "color_get_red", color_get_red,
			        "color_get_hue", color_get_hue,
			        "color_get_saturation", color_get_saturation,
			        "color_get_value", color_get_value,
			        "make_color_rgb", make_color_rgb,
			        "make_color_hsv", make_color_hsv,
			        "merge_color", merge_color
			    )
			#endregion
			
			#region Rendering
				addConstant(
					"FA_LEFT", fa_left,
					"FA_CENTER", fa_center,
					"FA_RIGHT", fa_right,
					
					"FA_TOP", fa_top,
					"FA_MIDDLE", fa_middle,
					"FA_BOTTOM", fa_bottom,
					
					"BM_NORMAL", bm_normal,
					"BM_ADD", bm_add,
					"BM_SUBTRACT", bm_subtract,
					"BM_MAX", bm_max,
					
					"BM_ZERO", bm_zero,
					"BM_ONE", bm_one,
					"BM_SRC_COLOR", bm_src_color,
					"BM_INV_SRC_COLOR", bm_inv_src_color,
					"BM_SRC_ALPHA", bm_src_alpha,
					"BM_INV_SRC_ALPHA", bm_inv_src_alpha,
					"BM_DEST_ALPHA", bm_dest_alpha,
					"BM_INV_DEST_ALPHA", bm_inv_dest_alpha,
					"BM_DEST_COLOR", bm_dest_color,
					"BM_INV_DEST_COLOR", bm_inv_dest_color,
					"BM_SRC_ALPHA_SAT", bm_src_alpha_sat,
					
					"PR_POINT_LIST", pr_pointlist,
					"PR_LINE_LIST", pr_linelist,
					"PR_LINE_STRIP", pr_linestrip,
					"PR_TRIANGLE_LIST", pr_trianglelist,
					"PR_TRIANGLE_STRIP", pr_trianglestrip,
					"PR_TRIANGLE_FAN", pr_trianglefan
				)
				
				addFunction(
					"gpu_get_tex_filter", gpu_get_tex_filter,
					"gpu_get_blendmode", gpu_get_blendmode,
					"gpu_get_blendmode_ext", gpu_get_blendmode_ext,
					"gpu_get_blendmode_ext_sepalpha", gpu_get_blendmode_ext_sepalpha,
					"gpu_get_blendmode_src", gpu_get_blendmode_src,
					"gpu_get_blendmode_dest", gpu_get_blendmode_dest,
					"gpu_get_blendmode_srcalpha", gpu_get_blendmode_srcalpha,
					"gpu_get_blendmode_destalpha", gpu_get_blendmode_destalpha,
					
					"gpu_set_tex_filter", gpu_set_tex_filter,
					"gpu_set_blendmode", gpu_set_blendmode,
					"gpu_set_blendmode_ext", gpu_set_blendmode_ext,
					"gpu_set_blendmode_ext_sepalpha", gpu_set_blendmode_ext_sepalpha,
					
					"draw_get_color", draw_get_color,
					"draw_get_alpha", draw_get_alpha,
					"draw_get_font", draw_get_font,
					"draw_get_halign", draw_get_halign,
					"draw_get_valign", draw_get_valign,
					
					"draw_set_color", draw_set_color,
					"draw_set_alpha", draw_set_alpha,
					"draw_set_font", draw_set_font,
					"draw_set_halign", draw_set_halign,
					"draw_set_valign", draw_set_valign,
					
					"draw_arrow", draw_arrow,
					"draw_circle", draw_circle,
					"draw_circle_color", draw_circle_color,
					"draw_ellipse", draw_ellipse,
					"draw_ellipse_color", draw_ellipse_color,
					"draw_line", draw_line,
					"draw_line_color", draw_line_color,
					"draw_line_width", draw_line_width,
					"draw_line_width_color", draw_line_width_color,
					"draw_point", draw_point,
					"draw_point_color", draw_point_color,
					"draw_rectangle", draw_rectangle,
					"draw_rectangle_color", draw_rectangle_color,
					"draw_roundrect", draw_roundrect,
					"draw_roundrect_color", draw_roundrect_color,
					"draw_roundrect_ext", draw_roundrect_ext,
					"draw_roundrect_color_ext", draw_roundrect_color_ext,
					"draw_triangle", draw_triangle,
					"draw_triangle_color", draw_triangle_color,
					
					"draw_text", draw_text,
					"draw_text_ext", draw_text_ext,
					"draw_text_color", draw_text_color,
					"draw_text_transformed", draw_text_transformed,
					"draw_text_ext_color", draw_text_ext_color,
					"draw_text_ext_transformed", draw_text_ext_transformed,
					"draw_text_transformed_color", draw_text_transformed_color,
					"draw_text_ext_transformed_color", draw_text_ext_transformed_color,
					
					"draw_primitive_begin", draw_primitive_begin,
					"draw_primitive_end", draw_primitive_end,
					"draw_vertex", draw_vertex,
					"draw_vertex_color", draw_vertex_color,
					
					"shader_reset", shader_reset
				)
			#endregion
		#endregion
		
		#region PNEngine
			#region Debug
				addFunction(
					"print", print,
					
					"show_error", function (_str) {
						show_error(_str, true)
					},
					
					"show_caption", show_caption
				)
			#endregion
			
			#region String
				addFunction(
					"string_localize", lexicon_text,
					"string_rich", scribble,
					
					"string_input", function (_verb, _player_index = 0) {
						return input_binding_get_name(input_binding_get(_verb, _player_index))
					}
				)
			#endregion
			
			#region Assets
				addConstant(
					"IMAGES", global.images,
					"MATERIALS", global.materials,
					"MODELS", global.models,
					"ANIMATIONS", global.animations,
					"FONTS", global.fonts,
					"SOUNDS", global.sounds,
					"MUSIC", global.music,
					
					"ANI_LINEAR", AnimationTypes.LINEAR,
					"ANI_LINEAR", AnimationTypes.LINEAR_LOOP,
					"ANI_QUADRATIC", AnimationTypes.QUADRATIC,
					"ANI_QUADRATIC_LOOP", AnimationTypes.QUADRATIC_LOOP
				)
				
				addFunction(
					"thing_load", thing_load,
					"transition_load", transition_load,
					
					"mod_get", function (_name) {
						return global.mods[? _name]
					},
					
					"MusicInstance", MusicInstance,
					
					"music_get_instance", function (_priority) {
						return global.music_instances[| _priority]
					}
				)
			#endregion
			
			#region Players
				addConstant(
					"MAX_PLAYERS", INPUT_MAX_PLAYERS,
					
					"PS_INACTIVE", PlayerStatus.INACTIVE,
					"PS_READY", PlayerStatus.PENDING,
					"PS_ACTIVE", PlayerStatus.ACTIVE,
					
					"INPUT_INVERSE", PLAYER_INPUT_INVERSE,
					"INPUT_UP_DOWN", PlayerInputs.UP_DOWN,
					"INPUT_LEFT_RIGHT", PlayerInputs.LEFT_RIGHT,
					"INPUT_JUMP", PlayerInputs.JUMP,
					"INPUT_INTERACT", PlayerInputs.INTERACT,
					"INPUT_ATTACK", PlayerInputs.ATTACK,
					"INPUT_INVENTORY_UP", PlayerInputs.INVENTORY_UP,
					"INPUT_INVENTORY_LEFT", PlayerInputs.INVENTORY_LEFT,
					"INPUT_INVENTORY_DOWN", PlayerInputs.INVENTORY_DOWN,
					"INPUT_INVENTORY_RIGHT", PlayerInputs.INVENTORY_RIGHT,
					"INPUT_AIM", PlayerInputs.AIM,
					"INPUT_AIM_UP_DOWN", PlayerInputs.AIM_UP_DOWN,
					"INPUT_AIM_LEFT_RIGHT", PlayerInputs.AIM_LEFT_RIGHT,
					"INPUT_FORCE_UP_DOWN", PlayerInputs.FORCE_UP_DOWN,
					"INPUT_FORCE_LEFT_RIGHT", PlayerInputs.FORCE_LEFT_RIGHT,
				)
				
				addFunction(
					"player_get", function (_index) {
						return global.players[_index]
					},
					
					"players_ready", function () {
						return global.players_ready
					},
					
					"players_active", function () {
						return global.players_active
					},
					
					"player_binding_label", function (_verb, _index = 0) {
						return input_binding_get_name(input_binding_get(_verb, _index))
					}
				)
			#endregion
			
			#region Level
				var _flags = global.flags
				
				addConstant(
					"GLOBAL", _flags[0],
					"LOCAL", _flags[1],
					
					"CP_LEVEL", 0,
					"CP_AREA", 1,
					"CP_TAG", 2
				)
				
				addFunction(
					"checkpoint_get", function (_index) {
						return global.checkpoint[_index]
					}
				)
			#endregion
			
			#region Things
				addConstant(
					"NO_THING", noone,
					
					"TAG_PLAYERS", ThingTags.PLAYERS,
					"TAG_FRIENDS", ThingTags.FRIENDS,
					"TAG_ENEMIES", ThingTags.ENEMIES,
					"TAG_NONE", ThingTags.NONE,
					"TAG_ALL", ThingTags.ALL,
					
					"M_COLLISION_NONE", MCollision.NONE,
					"M_COLLISION_NORMAL", MCollision.NORMAL,
					"M_COLLISION_BOUNCE", MCollision.BOUNCE,
					"M_COLLISION_PROJECTILE", MCollision.PROJECTILE,
					
					"M_BUMP_NONE", MBump.NONE,
					"M_BUMP_ALL", MBump.ALL,
					"M_BUMP_TO", MBump.TO,
					"M_BUMP_FROM", MBump.FROM,
					
					"M_SHADOW_NONE", MShadow.NONE,
					"M_SHADOW_NORMAL", MShadow.NORMAL,
					"M_SHADOW_BONE", MShadow.BONE,
					
					"DMG_NONE", DamageResults.NONE,
					"DMG_MISSED", DamageResults.MISSED,
					"DMG_BLOCKED", DamageResults.BLOCKED,
					"DMG_DAMAGED", DamageResults.DAMAGED,
					"DMG_FATAL", DamageResults.FATAL,
					
					"NVAR_DEFAULT", NetVarFlags.DEFAULT,
					"NVAR_CREATE", NetVarFlags.CREATE,
					"NVAR_TICK", NetVarFlags.TICK,
					"NVAR_GENERIC", NetVarFlags.GENERIC
				)
				
				addFunction("thing_exists", instance_exists)
			#endregion
			
			#region Collision
				addConstant(
					"TRIANGLE_X1", TriangleData.X1,
					"TRIANGLE_Y1", TriangleData.Y1,
					"TRIANGLE_Z1", TriangleData.Z1,
					"TRIANGLE_X2", TriangleData.X2,
					"TRIANGLE_Y2", TriangleData.Y2,
					"TRIANGLE_Z2", TriangleData.Z2,
					"TRIANGLE_X3", TriangleData.X3,
					"TRIANGLE_Y3", TriangleData.Y3,
					"TRIANGLE_Z3", TriangleData.Z3,
					"TRIANGLE_NX", TriangleData.NX,
					"TRIANGLE_NY", TriangleData.NY,
					"TRIANGLE_NZ", TriangleData.NZ,
					"TRIANGLE_SURFACE", TriangleData.SURFACE,
					"TRIANGLE_FLAGS", TriangleData.FLAGS,
					"TRIANGLE_LAYERS", TriangleData.LAYERS,
					
					"CFLAG_BODY", CollisionFlags.BODY,
					"CFLAG_BULLET", CollisionFlags.BULLET,
					"CFLAG_VISION", CollisionFlags.VISION,
					"CFLAG_CAMERA", CollisionFlags.CAMERA,
					"CFLAG_ALL", CollisionFlags.ALL,
					
					"CLAYER_0", CollisionLayers._0,
					"CLAYER_1", CollisionLayers._1,
					"CLAYER_2", CollisionLayers._2,
					"CLAYER_3", CollisionLayers._3,
					"CLAYER_4", CollisionLayers._4,
					"CLAYER_5", CollisionLayers._5,
					"CLAYER_6", CollisionLayers._6,
					"CLAYER_7", CollisionLayers._7,
					"CLAYER_ALL", CollisionLayers.ALL,
					
					"RAY_HIT", RaycastData.HIT,
					"RAY_X", RaycastData.X,
					"RAY_Y", RaycastData.Y,
					"RAY_Z", RaycastData.Z,
					"RAY_NX", RaycastData.NX,
					"RAY_NY", RaycastData.NY,
					"RAY_NZ", RaycastData.NZ,
					"RAY_SURFACE", RaycastData.SURFACE,
					"RAY_THING", RaycastData.THING,
					"RAY_TRIANGLE", RaycastData.TRIANGLE
				)
			#endregion
			
			#region Rendering
				addConstant(
					"SH_WORLD", global.world_shader,
					"SH_SKY", global.sky_shader,
					"SH_BLOOM_PASS", global.bloom_pass_shader,
					"SH_BLOOM", global.bloom_shader,
					"SH_CURVE", global.curve_shader,
					"SH_DEPTH", global.depth_shader,
					
					"U_AMBIENT_COLOR", global.u_ambient_color,
					"U_COLOR", global.u_color,
					"U_FOG_DISTANCE", global.u_fog_distance,
					"U_FOG_COLOR", global.u_fog_color,
					"U_MATERIAL_ALPHA_TEST", global.u_material_alpha_test,
					"U_MATERIAL_BRIGHT", global.u_material_bright,
					"U_MATERIAL_COLOR", global.u_material_color,
					"U_MATERIAL_SCROLL", global.u_material_scroll,
					"U_MATERIAL_SPECULAR", global.u_material_specular,
					"U_MATERIAL_WIND", global.u_material_wind,
					"U_CURVE", global.u_curve,
					
					"PART_DEAD", ParticleData.DEAD,
					"PART_IMAGE", ParticleData.IMAGE,
					"PART_FRAME", ParticleData.FRAME,
					"PART_FRAME_SPEED", ParticleData.FRAME_SPEED,
					"PART_ANIMATION", ParticleData.ANIMATION,
					"PART_ALPHA_TEST", ParticleData.ALPHA_TEST,
					"PART_WIDTH", ParticleData.WIDTH,
					"PART_WIDTH_SPEED", ParticleData.WIDTH_SPEED,
					"PART_HEIGHT", ParticleData.HEIGHT,
					"PART_HEIGHT_SPEED", ParticleData.HEIGHT_SPEED,
					"PART_ANGLE", ParticleData.ANGLE,
					"PART_ANGLE_SPEED", ParticleData.ANGLE_SPEED,
					"PART_COLOR", ParticleData.COLOR,
					"PART_ALPHA", ParticleData.ALPHA,
					"PART_ALPHA_SPEED", ParticleData.ALPHA_SPEED,
					"PART_BRIGHT", ParticleData.BRIGHT,
					"PART_BRIGHT_SPEED", ParticleData.BRIGHT_SPEED,
					"PART_TICKS", ParticleData.TICKS,
					"PART_X", ParticleData.X,
					"PART_Y", ParticleData.Y,
					"PART_Z", ParticleData.Z,
					"PART_FLOOR_Z", ParticleData.FLOOR_Z,
					"PART_CEILING_Z", ParticleData.CEILING_Z,
					"PART_X_SPEED", ParticleData.X_SPEED,
					"PART_Y_SPEED", ParticleData.Y_SPEED,
					"PART_Z_SPEED", ParticleData.Z_SPEED,
					"PART_X_FRICTION", ParticleData.X_FRICTION,
					"PART_Y_FRICTION", ParticleData.Y_FRICTION,
					"PART_Z_FRICTION", ParticleData.Z_FRICTION,
					"PART_GRAVITY", ParticleData.GRAVITY,
					"PART_MAX_FLY_SPEED", ParticleData.MAX_FLY_SPEED,
					"PART_MAX_FALL_SPEED", ParticleData.MAX_FALL_SPEED,
					
					"PANI_PLAY", ParticleAnimations.PLAY,
					"PANI_PLAY_STAY", ParticleAnimations.PLAY_STAY,
					"PANI_LOOP", ParticleAnimations.LOOP
				)
				
				addFunction(
					"Canvas", Canvas,
					"ModelInstance", ModelInstance,
					"interp", interp,
					"interp_skip", interp_skip,
					
					"shader_current", function () {
						return global.current_shader
					},
					
					"draw_image", CollageDrawImage,
					"draw_image_ext", CollageDrawImageExt,
					"draw_image_general", CollageDrawImageGeneral,
					"draw_image_stretched", CollageDrawImageStretched,
					"draw_image_stretched_ext", CollageDrawImageStretchedExt,
					"draw_image_part", CollageDrawImagePart,
					"draw_image_part_ext", CollageDrawImagePartExt,
					"draw_image_tiled", CollageDrawImageTiled,
					"draw_image_tiled_ext", CollageDrawImageTiledExt,
					
					"batch_billboard", batch_billboard,
					"batch_floor", batch_floor,
					"batch_floor_ext", batch_floor_ext,
					"batch_line", batch_line,
					"batch_set_alpha_test", batch_set_alpha_test,
					"batch_set_bright", batch_set_bright
				)
			#endregion
			
			#region Game
				addConstant(
					"GAME_DEFAULT", GameStatus.DEFAULT,
					"GAME_NETGAME", GameStatus.NETGAME,
					"GAME_DEMO", GameStatus.DEMO,
					
					"TICKRATE", TICKRATE,
					
					"TOPT_NEW_FILE", TitleOptions.NEW_FILE,
					"TOPT_LOAD_FILE", TitleOptions.LOAD_FILE,
					"TOPT_DELETE_FILE", TitleOptions.DELETE_FILE,
					"TOPT_OPTIONS", TitleOptions.OPTIONS
				)
				
				addFunction(
					"game_status", function () {
						return global.game_status
					},
					
					"game_master", function () {
						var _netgame = global.netgame
						
						if _netgame != undefined {
							return _netgame.master
						}
						
						return true
					},
					
					"delta_time", function () {
						return global.delta
					}
				)
			#endregion
			
			#region UI
				addConstant(
					"UINP_UP_DOWN", UIInputs.UP_DOWN,
					"UINP_LEFT_RIGHT", UIInputs.LEFT_RIGHT,
					"UINP_CONFIRM", UIInputs.CONFIRM,
					"UINP_BACK", UIInputs.BACK
				)
				
				addFunction(
					"ui_create", ui_create,
					"ui_exists", ui_exists
				)
			#endregion
		#endregion
	}
#endregion

// CREATE
ui_font = scribble_fallback_font
ui_font_name = ""
chat_font = scribble_fallback_font
chat_font_name = ""
chat_sound = undefined

var _custom_ui_font = undefined
var _custom_chat_font = undefined
var _custom_chat_sound = undefined

#region Mods
	var _mods = global.mods
	var _key = ds_map_find_first(_mods)

	repeat ds_map_size(_mods) {
		var _mod = _mods[? _key]
		var _path = _mod.path
		var _languages = _path + "languages/languages.json"
	
		if file_exists(_languages) {
			lexicon_index_definitions(_languages)
		}
		
		var _info = json_load(_path + "mod.json")
		
		if is_struct(_info) {
			var _title = string(_info[$ "title"])
			
			if is_string(_title) {
				window_set_caption(_title)
			}
			
			var _version = _info[$ "version"]
			
			if is_string(_version) {
				_mod.version = _version
			}
			
			var _rpc_id = _info[$ "rpc"]
			
			if is_string(_rpc_id) {
				global.game_rpc_id = _rpc_id
			}
			
			var _flags = _info[$ "flags"]
			
			if is_struct(_flags) {
				var _default_flags = global.default_flags
				var _names = struct_get_names(_flags)
				var i = 0
				
				repeat struct_names_count(_flags) {
					var _key = _names[i]
					
					_default_flags[? _key] = _flags[$ _key];
					++i
				}
			}
			
			var _ui_font = _info[$ "ui_font"]
			
			if is_string(_ui_font) {
				_custom_ui_font = _ui_font
			}
			
			var _chat_font = _info[$ "chat_font"]
			
			if is_string(_chat_font) {
				_custom_chat_font = _chat_font
			}
			
			var _chat_sound = _info[$ "chat_sound"]
			
			if is_string(_chat_sound) {
				_custom_chat_sound = _chat_sound
			}
		}
		
		_key = ds_map_find_next(_mods, _key)
	}
	
	global.flags[0].clear()
#endregion

#region Language
	lexicon_index_fallback_language_set("English")
	lexicon_language_set("English")
#endregion

config_update()

// MESSAGE
var _fonts = global.fonts

if is_string(_custom_ui_font) {
	var _font = _fonts.fetch(_custom_ui_font)
	
	ui_font = _font.font
	ui_font_name = _font.name
	_font.transient = true
}

if is_string(_custom_chat_font) {
	var _font = _fonts.fetch(_custom_chat_font)
	
	chat_font = _font.font
	chat_font_name = _font.name
	_font.transient = true
}

if is_string(_custom_chat_sound) {
	chat_sound = global.sounds.fetch(_custom_chat_sound)
	chat_sound.transient = true
}

caption = scribble("", "__PNENGINE_CAPTION__").starting_format(ui_font_name, c_white)
caption_time = -1

// LEVEL
load_level = "lvlLogo"
load_area = 0
load_tag = noone
load_state = LoadStates.START

// DISCORD
if not np_initdiscord(global.game_rpc_id, true, np_steam_app_id_empty) {
	print("! proControl: Could not initialize Discord Rich Presence")
}