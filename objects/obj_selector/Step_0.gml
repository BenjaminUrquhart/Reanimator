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


if index < 0 index = count - 1
if index >= count index = 0


if keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) {
	hold_dir = HoldDir.NONE
	hold_timer = wait_time
	submit(id, index)	
}
