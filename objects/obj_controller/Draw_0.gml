draw_set_font(fnt_main)

var len = ds_exists(message_queue, ds_type_list) ? ds_list_size(message_queue) : 0
if len {
	var yy = 10
	for(var i = len - 1; i >= 0; i--) {
		var msg = message_queue[| i]
		draw_set_alpha(msg.alpha)
		draw_set_color(msg.color)
		draw_text(room_width/5 + 10, yy, msg.message)
		if msg.timer > 0 {
			msg.timer--	
		}
		else {
			msg.alpha -= 1 / (game_get_speed(gamespeed_fps) * 1.5)
			if msg.alpha <= 0 {
				ds_list_delete(message_queue, i)
				len--
				i--
			}
		}
		yy += string_height(msg.message)
	}
}

draw_set_alpha(1)

if global.show_boxes {
	var xx = ((room_width * 0.8) / 2) + (room_width / 5)
	var yy = room_height / 2
	draw_set_color(c_fuchsia)
	draw_rectangle(xx - RPG_WINDOW_WIDTH / 2, yy - RPG_WINDOW_HEIGHT / 2, xx + RPG_WINDOW_WIDTH / 2, yy + RPG_WINDOW_HEIGHT / 2, true)
}