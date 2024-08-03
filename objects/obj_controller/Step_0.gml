if keyboard_check_pressed(vk_up) {
	hold_dir = HoldDir.UP
	hold_timer = wait_time
	index--	
}
if keyboard_check_pressed(vk_down) {
	hold_dir = HoldDir.DOWN
	hold_timer = wait_time
	index++	
}

if hold_dir == HoldDir.UP {
	if keyboard_check(vk_up) {
		if hold_timer < 1 {
			cooldown--
			if cooldown <= 0 {
				index--
				cooldown = 1
			}
		}
		else {
			hold_timer--	
		}
	}
	else {
		hold_timer = wait_time
		hold_dir = HoldDir.NONE
	}
}
else if hold_dir == HoldDir.DOWN {
	if keyboard_check(vk_down) {
		if hold_timer < 1 {
			cooldown--
			if cooldown <= 0 {
				index++
				cooldown = 1
			}
		}
		else {
			hold_timer--	
		}
	}
	else {
		hold_timer = wait_time
		hold_dir = HoldDir.NONE
	}
}


if index < 0 index = 0
if index >= num_animations index = num_animations - 1


// TODO: pausing, stepping forwards/backwards and changing playback speed


if global.data_animations[index] && keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) {
	hold_dir = HoldDir.NONE
	hold_timer = wait_time
	audio_stop_all()
	
	error_text = ""
	if instance_exists(player) && player.anim.id == index {
		player.reset()
	}
	else {
		instance_destroy(player)
		
		// TODO: better handing, maybe pause the animation
		// if something goes wrong part way
		try {
			player = instance_create_layer(0, 0, "Flash", obj_animation_player, { anim: global.data_animations[index] })	
		}
		catch(e) {
			show_debug_message(e.message)
			show_debug_message(e.stacktrace)
			with(obj_animation_player) {
				// sprites don't exist at this stage
				instance_destroy(id, false)	
			}
			error_text = $"Error playing animation:\n{e.message}"
		}
	}
}

