index += dir

if index >= num_frames {
	switch loop_modes[state] {
		case LoopMode.BACK_AND_FORTH: {
			dir = -1
			index = num_frames - 2
		} break
		case LoopMode.SIMPLE: {
			index = 0
		} break
	}

}
else if index < 0 {
	index = 1
	dir = 1
}

index = clamp(index, 0, num_frames)

alarm[0] = timer