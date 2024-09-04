enum HoldDir {
	NONE,
	UP,
	DOWN
}

entry_height = -1
num_fit = -1

index = 0
buffer_space = 3
count = array_length(names)

highlighted = -1

cooldown = 0
hold_timer = -1
hold_dir = HoldDir.NONE
cooldown_start = round(game_get_speed(gamespeed_fps) / 15)

wait_time = 7 * cooldown_start

hovered = -1

update = function(menu) {
	names = menu.names
	count = array_length(names)
	submit = menu.submit
	name = menu.name
	highlighted = -1
}