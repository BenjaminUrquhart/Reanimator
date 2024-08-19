if !started {
	alarm[0] = timer
	started = true
}
if is_sv_actor && !controls_locked {
	if keyboard_check_pressed(vk_left) state--
	if keyboard_check_pressed(vk_right) state++
	state = clamp(state, 0, SVActorState.LAST - 1)
}
