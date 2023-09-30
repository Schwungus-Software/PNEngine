/// @description Draw Screen
if screen_camera == camera {
	if player != undefined and (global.players_active > 1 or player.slot != 0) {
		draw_set_halign(fa_center)
		draw_text(screen_width * 0.5, 8, lexicon_text("hud.player", -~(player.slot)))
		draw_set_halign(fa_left)
	}
}

event_inherited()