index += dir

if index >= 3 {
	dir = -1
	index = 1
}
else if index < 0 {
	index = 1
	dir = 1
}

alarm[0] = timer