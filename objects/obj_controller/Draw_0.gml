draw_set_alpha(1)
draw_set_font(fnt_main)

if error_text != "" {
	draw_set_color(c_red)
	draw_text(room_width/5 + 10, 10, error_text)
}

if global.show_boxes {
	var xx = ((room_width * 0.8) / 2) + (room_width / 5)
	var yy = room_height / 2
	draw_set_color(c_fuchsia)
	draw_rectangle(xx - RPG_WINDOW_WIDTH / 2, yy - RPG_WINDOW_HEIGHT / 2, xx + RPG_WINDOW_WIDTH / 2, yy + RPG_WINDOW_HEIGHT / 2, true)
}