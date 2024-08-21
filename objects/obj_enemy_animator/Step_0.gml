if !visible {
	if is_sv_actor {
		started = false
		alarm[0] = -1	
	}
	return
}

if !started {
	alarm[0] = timer
	started = true
}
if is_sv_actor && !controls_locked {
	if keyboard_check_pressed(vk_left) state--
	if keyboard_check_pressed(vk_right) state++
	
	if state < 0 state = num_states - 1
	if state >= num_states state = 0
}
