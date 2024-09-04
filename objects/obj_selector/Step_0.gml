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
				cooldown = cooldown_start
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
				cooldown = cooldown_start
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
else if mouse_wheel_down() {
	index++	
}
else if mouse_wheel_up() {
	index--	
}


if index < 0 index = count - 1
if index >= count index = 0

if count > 0 && mouse_x < room_width / 5 && num_fit > 0 {
	var offset = max(0, index - floor(num_fit/2))
	if offset + num_fit >= count {
		offset = count - num_fit	
	}
	hovered = clamp(offset + floor(mouse_y / entry_height) - 1, 0, count - 1)
	window_set_cursor(cr_handpoint)	
	if mouse_check_button_released(mb_left) {
		submit(id, hovered)
		index = hovered
	}
}
else if hovered != -1 {
	hovered = -1
	if window_has_focus() {
		window_set_cursor(cr_arrow)	
	}
}


if keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) {
	hold_dir = HoldDir.NONE
	hold_timer = wait_time
	submit(id, index)
}

