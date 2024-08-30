var scale = 1

var drawx, drawy;

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
			surface = surface_create(width, height)		
		}
	}

	surface_set_target(surface)
	draw_clear_alpha(c_black, 0)


	if state == -1 {
		var dx = 0
		var dy = 0
		for(var i = 0; i < num_state; i++) {
			draw_state(dx, dy, i)
			dx += width
			if dx >= sheetw {
				dx = 0
				dy += height
			}
		}
	}
	else {
		draw_state(0, 0)
	}
	
	drawx = x - (width * scale) / 2
	drawy = y - (height * scale) / 2
	
}
else {
	if !surface_exists(surface) {
		surface = surface_create(width, height)	
	}
	surface_set_target(surface)
	draw_clear_alpha(c_black, 0)

	draw_sprite(sheet, 0, 0, 0)
	drawx = x - (width * scale) / 2
	drawy = y - (height * scale) / 2
}

surface_reset_target()

if hide_frames < 1 {
	draw_surface_ext(surface, drawx, drawy, scale, scale, 0, c_white, 1)

	if flash_frames > 0 {
		gpu_set_fog(true, c_white, 0, 0)
		draw_surface_ext(surface, drawx, drawy, scale, scale, 0, c_white, flash_alpha * (flash_frames / flash_max_frames))
		gpu_set_fog(false, c_white, 0, 0)
	
		if step_flash {
			step_flash = false
			flash_frames--
		}
	}
}
else if step_hide {
	step_hide = false
	hide_frames--
}


draw_set_alpha(1)
draw_set_color(c_red)
draw_set_font(fnt_main)
draw_set_halign(fa_right)
draw_text(room_width - 10, 10, $"{actor}\n" + ((is_sv_actor ? $"{state + 1}/{num_states}" : "N/A")))
draw_set_halign(fa_left)