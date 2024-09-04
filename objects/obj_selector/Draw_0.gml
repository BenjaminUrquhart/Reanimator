draw_set_alpha(0.75)
draw_set_font(fnt_main)
draw_set_color(c_black)
draw_rectangle(0, 0, room_width/5, room_height, false)

entry_height = string_height("A") + buffer_space
num_fit = floor(room_height / entry_height) - 1

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

draw_set_color(c_white)
draw_rectangle(0, 0, room_width/5, entry_height, false)

draw_set_alpha(1)
draw_set_color(c_black)
draw_text(10, 0, $"{name} {index}/{count - 1} {hovered}")

for(var i = start; i < stop; i++) {
	
	var entry_y = entry_height * (i - start + 1) + buffer_space
	
	if i >= count break
	
	if i == hovered {
		draw_set_color(c_white)
		draw_rectangle(5, entry_y, room_width/5, entry_y + entry_height, true)
	}
	
	if i == index {
		draw_set_color(c_yellow)	
	}
	else if i == highlighted {
		draw_set_color(c_orange)	
	}
	else {
		draw_set_color(c_white)	
	}
	draw_text(10, entry_y, names[i])
}

