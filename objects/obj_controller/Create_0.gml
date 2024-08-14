enum HoldDir {
	NONE,
	UP,
	DOWN
}

index = 0
buffer_space = 3
num_animations = array_length(global.data_animations)

player = noone

cooldown = 0
hold_timer = -1
hold_dir = HoldDir.NONE
cooldown_start = round(game_get_speed(gamespeed_fps) / 15)

error_text = ""

wait_time = 7 * cooldown_start