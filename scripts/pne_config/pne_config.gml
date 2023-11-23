#macro TICKRATE 30 // The update rate (base FPS) of the game
#macro TICKRATE_DELTA 0.00003 // (TICKRATE / 1000000)

#macro LOGS_PATH game_save_id + "logs/"
#macro SAVES_PATH game_save_id + "saves/"
#macro CONFIG_PATH game_save_id + "config.json"
#macro CONTROLS_PATH game_save_id + "controls.json"

config_load()