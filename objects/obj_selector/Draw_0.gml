draw_set_alpha(0.75)
draw_set_font(fnt_main)
draw_set_color(c_black)
draw_rectangle(0, 0, room_width/5, room_height, false)

draw_set_alpha(1)

var height = string_height("A") + buffer_space;
var num_fit = floor(room_height / height)

var start = index - floor(num_fit/2)
var stop = index + ceil(num_fit/2)

if stop > count {
	start -= (stop - count)
	stop = count
}

if start < 0 {
	stop -= start
	start = 0
}

for(var i = start; i < stop; i++) {
	
	if i >= count break;
	
	if i == index {
		draw_set_color(c_yellow)	
	}
	else if i == highlighted {
		draw_set_color(c_orange)	
	}
	else {
		draw_set_color(c_white)	
	}
	draw_text(10, height * (i - start) + buffer_space, names[i])
}

