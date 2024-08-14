var scale = 1

if is_sv_actor {
	if previous_sheet != sheet || previous_state * state < 0 {
		surface_free(surface)
		previous_sheet = sheet
		previous_state = state
	}

	if !surface_exists(surface) {
		if state == -1 {
			surface = surface_create(sprite_get_width(sheet) / 3, sprite_get_height(sheet))		
		}
		else {
			surface = surface_create(sprite_get_width(sheet) / 9, sprite_get_height(sheet) / 6)		
		}
	}

	var surfw = surface_get_width(surface)
	var surfh = surface_get_height(surface)

	var slidew = sprite_get_width(sheet) / 9
	var slideh = sprite_get_height(sheet) / 6

	surface_set_target(surface)
	draw_clear_alpha(c_black, 0)


	if state == -1 {
		var dx = 0
		var dy = 0
		for(var i = 0; i < SVActorState.LAST; i++) {
			draw_state(dx, dy, i)
			dx += slidew
			if dx >= surfw {
				dx = 0
				dy += slideh
			}
		}
	}
	else {
		draw_state(0, 0)
	}
	surface_reset_target()
	draw_surface_ext(surface, (room_width - slidew * scale) / 2, (room_height - slideh * scale) / 2, scale, scale, 0, c_white, 1)
}
else {
	var ww = sprite_get_width(sheet)
	var hh = sprite_get_height(sheet)
	draw_sprite_ext(sheet, 0, (room_width - ww * scale) / 2, (room_height - hh * scale) / 2, scale, scale, 0, c_white, 1)	
}

draw_set_alpha(1)
draw_set_color(c_red)
draw_set_font(fnt_main)
draw_set_halign(fa_right)
draw_text(room_width - 10, 10, $"{actor}\n{(is_sv_actor ? string(state) : "N/A")}")
draw_set_halign(fa_left)