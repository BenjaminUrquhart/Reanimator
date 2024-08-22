if is_undefined(anim) {
	do_throw("No animation set")
	return;
}

data1 = rpg_get_animation_sheet(anim.animation1Name)
data2 = rpg_get_animation_sheet(anim.animation2Name)

sheet1 = data1.sheet
sheet2 = data2.sheet
blend1 = c_white
blend2 = c_white

rpg_claim_assets([data1.key, data2.key])

current_frame = 0
num_frames = array_length(anim.frames)

sprites = []
num_sprites = 0

list_index = anim.id

previous_frame = -1

reset = function() {
	for(var i = 0; i < num_sprites; i++) {
		sprites[i].visible = false;	
	}
	previous_frame = -1
	current_frame = 0
	step_flash = true
}

framerate = 15