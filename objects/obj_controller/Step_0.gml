global.show_boxes = keyboard_check(vk_shift)

if keyboard_check_pressed(vk_alt) {
	global.show_dummy = !global.show_dummy
	if global.show_dummy {
		var pos = menu_positions[1]
		if !global.data_enemies[pos] {
			pos = 1
		}
		create_target(pos)	
	}
	else {
		instance_destroy(target)	
	}
}


if instance_exists(player) && player.playing {
	selector.highlighted = player.list_index
}
else {
	selector.highlighted = -1	
}	


var prev = menu
/*
if keyboard_check_pressed(vk_left) menu--
if keyboard_check_pressed(vk_right) menu++
*/
if keyboard_check_pressed(vk_tab) menu++
if menu < 0 menu = menu_count - 1
if menu >= menu_count menu = 0

if menu != prev {
	with(obj_animation_player) instance_destroy()
	if global.show_dummy {
		if instance_exists(obj_enemy_animator) {
			target = obj_enemy_animator.id
		}
		else {
			create_target()
		}	
	}
	else {
		with(obj_enemy_animator) instance_destroy()	
	}
	player = noone
	
	// Trust me feather I know what I'm doing
	// Feather ignore once GM2016
	selector.update(menus[menu])
	menu_positions[prev] = selector.index
	selector.index = menu_positions[menu]
}

// TODO: pausing, stepping forwards/backwards and changing playback speed