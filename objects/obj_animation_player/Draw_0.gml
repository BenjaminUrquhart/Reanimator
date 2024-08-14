if flash_frames > 0 {
	draw_set_color(flash_color)
	draw_set_alpha(flash_alpha * (flash_frames / flash_max_frames))
	draw_rectangle(room_width / 5, 0, room_width, room_height, false)
	if step_flash {
		step_flash = false
		flash_frames--
	}
}