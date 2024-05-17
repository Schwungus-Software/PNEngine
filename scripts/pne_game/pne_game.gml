#region Version Control
	global.build_date = date_datetime_string(GM_build_date)
#endregion

#region Game State
	enum GameStatus {
		DEFAULT,
		NETGAME = 1 << 0,
		DEMO = 1 << 1,
	}
	
	enum LoadStates {
		NONE,
		START,
		UNLOAD,
		LOAD,
		FINISH,
	}
	
	enum InterpData {
		IN,
		OUT,
		IN_HASH,
		OUT_HASH,
		PREVIOUS_VALUE,
		ANGLE,
	}
	
	global.game_status = GameStatus.DEFAULT
	global.game_rpc_id = ""
	
	global.freeze_step = true
	global.tick = 0
	global.tick_draw = 0
	global.tick_scale = 1
	global.tick_complete = false
	global.delta = 1
	global.mouse_focused = false
	global.mouse_start = false
	
	global.interps = ds_list_create()
	
	global.saves = ds_list_create()
	global.save_name = "Debug"
	global.title_start = true
	global.title_delete_state = 0
#endregion

#region Levels
	enum FlagGroups {
		GLOBAL,
		LOCAL,
		STATIC,
	}
	
	global.checkpoint = ["", 0, ThingTags.NONE]
	global.level = new Level()
	global.flags = [new Flags(0), new Flags(1), new Flags(2)]
	global.default_flags = ds_map_create()
#endregion

#region Things
	enum ThingEvents {
		LOAD,
		CREATE,
		TICK_START,
		TICK,
		TICK_END,
		DRAW,
		DRAW_SCREEN,
		DRAW_GUI,
	}
	
	enum ThingTags {
		PLAYERS = -1,
		FRIENDS = -2,
		ENEMIES = -3,
		NONE = -4, // noone
		ALL = -5,
		PLAYER_SPAWNS = -6,
	}
	
	enum DamageResults {
		NONE,
		MISSED,
		BLOCKED,
		DAMAGED,
		FATAL,
	}
#endregion