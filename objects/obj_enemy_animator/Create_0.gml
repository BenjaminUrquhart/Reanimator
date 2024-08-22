// I'm starting to think it would have been
// a good idea to make an RPGMaker MV game
// with these plugins before trying to dissect them

enum LoopMode {
	SIMPLE,
	BACK_AND_FORTH
}

surface = -1
loop_modes = undefined

if is_undefined(enemy) {
	do_throw("No enemy provided")
	instance_destroy()
	return;
}

// I would like to thank Omori for
// its excessive use of sideview
// battlers.

tags = rpg_ext_parse_notetags(enemy.note)
show_debug_message(tags)

is_sv_actor = tags.has("Sideview Battler")

sprite_key = ""

try {
	if is_sv_actor {
		actor = tags.get("Sideview Battler")
		timer = real(tags.get("Sideview Battler Speed", 12))
		sprite_key = RPG_GAME_BASE + "img/sv_actors/" + actor
		sheet = rpg_load_image(sprite_key)
	
		sheetw = sprite_get_width(sheet)
		sheeth = sprite_get_height(sheet)
	
		num_frames = real(tags.get("Sideview Battler Frames", 3))
	
		var dimension_str = tags.get("Sideview Battler Size")
		if dimension_str {
			var split = string_split(dimension_str, ", ", true, 2)
			width = real(split[0])
			height = real(split[1])
		}
		else {
			width = sheetw / (num_frames * 3)
			height = sheeth / 6
		}
	
		num_states = floor((sheetw / (width * num_frames)) * (sheeth / height))
	
		// Ok so, I'm not sure what setting I'm missing but
		// OMORI and In Stars And Time seem to loop their
		// sideview battlers differently. OMORI restarts at 0
		// while ISAT counts back down to 0 instead.
		//
		// OMORI: 0 1 2 3 0 1 2 3 0 1 2 3 0
		// ISAT:  0 1 2 3 2 1 0 1 2 3 2 1 0
		//
		// I can't figure out what determines this behavior and
		// I'm too tired to comb through the plugin code to
		// find out the hard way.
		// Set the default loop mode to BACK_AND_FORTH below
		// to make it work in ISAT, SIMPLE for OMORI.
		// Maybe I'll make this a UI toggle.
		// Alternatively, find another game that uses these.
		loop_modes = array_create(num_states, LoopMode.BACK_AND_FORTH)
	
		// An attempt at fixing the problem above
		// (OMORI does who knows what to handle emotions 
		//  so those will always be messed up).
		if tags.has("Sideview Battler Motion") {
		
			// Do some more processing of these tags
			var motions = tags.get("Sideview Battler Motion")
			var len = array_length(motions)
		
			// Single tag, convert to array of 1
			// for convenience later
			if is_string(motions[0]) {
				motions = [motions]
				with(tags) {
					tags[$ __lookup_key("Sideview Battler Motion")] = motions
				}
				len = 1
			}
		
			for(var i = 0; i < len; i++) {
				var motion = motions[i]
			
				if is_array(motion) {
					// This turns an array of strings like
					// ["key: value"] into a struct with members
					// {key: "value"}.
					var motion_map = {}
					var motion_len = array_length(motion)
					for(var j = 0; j < motion_len; j++) {
						var cmd = motion[j]
						var split_pos = string_pos(": ", cmd)
						if split_pos > 0 {
							motion_map[$ string_copy(cmd, 0, split_pos - 1)] = string_delete(cmd, 0, split_pos + 1)
						}
						else {
							motion_map[$ cmd] = true	
						}
					}
					motions[i] = motion_map
					motion = motion_map
				}
			
				// idk at this point this is like the only difference
				// (ISAT doesn't do any fancy stuff with the plugin)
				if !struct_exists(motion, "Name") && struct_exists(motion, "Index") {
					loop_modes[real(motion[$ "Index"])] = motion[$ "Loop"] ? LoopMode.SIMPLE : LoopMode.BACK_AND_FORTH
				}
			}
		
			show_debug_message(loop_modes)
		}
	}
	else {
		timer = 12
		num_frames = 1
		actor =  enemy.battlerName
		sprite_key = rpg_enemy_find_sprite(actor)
		sheet = rpg_load_image(sprite_key)
		loop_modes = [LoopMode.SIMPLE]
		width = sprite_get_width(sheet)
		height = sprite_get_height(sheet)
		sheetw = width
		sheeth = height
		num_states = 1
	}
}
catch(e) {
	with(obj_controller) submit_error(e)
	instance_destroy()
	return
}

rpg_claim_assets([sprite_key])

previous_sheet = sheet
previous_state = -1
state = 0

started = !is_sv_actor
index = 0
dir = 1

draw_state = function(dx, dy, state = self.state, index = self.index) {
	if !is_sv_actor {
		do_throw("Not an sv_actor")	
	}
	
	var rawx = (width * (state * num_frames + index))
	
	var xx = rawx % sheetw
	var yy = height * floor(rawx / sheetw)
	draw_sprite_part(sheet, 0, xx, yy, width, height, dx, dy)
	
	draw_set_alpha(1)
	draw_set_color(c_red)
	draw_set_font(fnt_main)
	draw_text(dx, dy, $"{xx} {yy} {index}")
}