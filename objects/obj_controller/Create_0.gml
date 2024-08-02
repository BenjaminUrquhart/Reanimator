enum HoldDir {
	NONE,
	UP,
	DOWN
}

index = 0
buffer_space = 3
num_animations = array_length(global.animations)

player = noone

cooldown = 0
hold_timer = -1
hold_dir = HoldDir.NONE

error_text = ""

wait_time = 7