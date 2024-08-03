draw_set_alpha(0.75)
draw_set_font(fnt_main)
draw_set_color(c_black)
draw_rectangle(0, 0, room_width/5, room_height, false)

draw_set_alpha(1)

if error_text != "" {
	draw_set_color(c_red)
	draw_text(room_width/5 + 10, 10, error_text)
}

var height = string_height("A") + buffer_space;
var num_fit = floor(room_height / height)

var start = index - floor(num_fit/2)
var stop = index + ceil(num_fit/2)

if stop > num_animations {
	start -= (stop - num_animations)
	stop = num_animations
}

if start < 0 {
	stop -= start
	start = 0
}

/*
draw_set_halign(fa_right)
draw_text(room_width-10, 10, $"{height} {start} {stop} {num_animations}")
draw_set_halign(fa_left)
*/

var playing = -1
if instance_exists(player) && player.playing {
	playing = player.anim.id
}

for(var i = start; i < stop; i++) {
	
	if i >= num_animations break;
	
	if i == index {
		draw_set_color(c_yellow)	
	}
	else if i == playing {
		draw_set_color(c_orange)	
	}
	else {
		draw_set_color(c_white)	
	}
	var anim = global.data_animations[i]
	draw_text(10, height * (i - start) + buffer_space, anim ? (anim.name == "" ? "---" : anim.name) : "<null>")
}
