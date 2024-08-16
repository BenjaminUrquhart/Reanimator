if sprite_exists(sprite_index) {
	if !surface_exists(surface) {
		surface = surface_create(sw, sh)
	}
	surface_set_target(surface)
	draw_clear_alpha(c_black, 0)
	draw_set_alpha(1)
	draw_sprite_part(sprite_index, 0, sx, sy, sw, sh, 0, 0)
	if global.show_boxes {
		draw_set_color(c_red)
		draw_rectangle(1, 1, sw - 2, sh - 2, true)	
	}
	surface_reset_target()
	
	var drawx = x - (sw * image_xscale) / 2
	var drawy = y - (sh * image_yscale) / 2
	
	// I love center origins yayyyyyyy
	if image_angle != 0 {
		var offsetx = -(sw * image_xscale) / 2
		var offsety = -(sh * image_yscale) / 2
		drawx = x + (offsetx * dcos(image_angle) + offsety * dsin(image_angle))
		drawy = y - (offsetx * dsin(image_angle) - offsety * dcos(image_angle))
	}
	
	draw_surface_ext(surface, drawx, drawy, image_xscale, image_yscale, image_angle, image_blend, image_alpha)
}