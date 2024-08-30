/// @description GIF render time
	
try {
	var base_path = game_save_id + player.actor
	if !directory_exists(base_path) {
		directory_create(base_path)
	}
	with player {
		var surf = surface_create(width, height)
		surface_set_target(surf)
		for(var state = 0; state < num_states; state++) {
			var gif = gif_open(width, height)
			for(var i = 0; i < num_frames; i++) {
				draw_clear_alpha(c_black, 0)
				draw_state(0, 0, state, i)
				gif_add_surface(gif, surf, (timer / game_get_speed(gamespeed_fps)) * 100)
			}
			if loop_modes[state] == LoopMode.BACK_AND_FORTH {
				for(var i = num_frames - 2; i > 0; i--) {
					draw_clear_alpha(c_black, 0)
					draw_state(0, 0, state, i)
					gif_add_surface(gif, surf, (timer / game_get_speed(gamespeed_fps)) * 100)
				}
			}
			if gif_save(gif, $"{base_path}/state_{state}.gif") < 0 {
				submit_message($"Failed to save state {state} for enemy {actor}")
			}
		}
	}
	submit_message("Finished")
}
catch(e) {
	submit_error(e)
}
finally {
	surface_reset_target()	
}