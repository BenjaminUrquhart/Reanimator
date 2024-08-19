if instance_exists(player) && player.playing {
	selector.highlighted = player.anim.id
}
else {
	selector.highlighted = -1	
}

var prev = menu
if keyboard_check_pressed(vk_left) menu--
if keyboard_check_pressed(vk_right) menu++
if menu < 0 menu = menu_count - 1
if menu >= menu_count menu = 0

if menu != prev {
	with(obj_animation_player) instance_destroy()
	with(obj_enemy_animator) instance_destroy()
	selector.update(menus[menu])
}

global.show_boxes = keyboard_check(vk_shift)

// TODO: pausing, stepping forwards/backwards and changing playback speed