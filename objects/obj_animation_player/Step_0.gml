if floor(current_frame) != previous_frame {
	
	step_flash = true
	step_hide = true
	
	previous_frame = floor(current_frame)
	var remainder = current_frame - floor(current_frame)
	current_frame = previous_frame
	
	if current_frame >= num_frames {
		for(var i = 0; i < num_sprites; i++) {
			sprites[i].visible = false;	
		}
		playing = false
		return;
	}

	playing = true


	var frame = anim.frames[current_frame]
	var num_cells = array_length(frame)

	// Make sure enough sprite slots exist
	while num_sprites < num_cells {
		sprites[num_sprites] = instance_create_layer(0, 0, "Sprites", obj_sprite)
		num_sprites++
	}
	// Hide sprites not in use
	for(var i = num_cells; i < num_sprites; i++) {
		sprites[i].visible = false;	
	}


	for(var i = 0; i < num_cells; i++) {
		var cell = frame[i]
		var sprite = sprites[i]
	
		// rpg_sprites.js: Sprite_Animation.prototype.updateCellSprite
		// slight modifications to make it look good in this engine.
		var pattern = cell[0];
		if pattern >= 0 {
			sprite.sx = (pattern % 5) * 192
			sprite.sy = floor((pattern % 100) / 5) * 192
			sprite.sprite_index = pattern < 100 ? sheet1 : sheet2
		
			// Offset into center of viewing area
			sprite.x = cell[1] + room_width / 5 + (room_width * .8) / 2
			sprite.y = cell[2] + room_height / 2
		
			// Gamemaker angles are backwards
			sprite.image_angle = -cell[4]
		
			sprite.image_xscale = cell[3] / 100
		
			if cell[5] {
				sprite.image_xscale *= -1	
			}
		
			// TODO: mirroring support?
			// This might be a code thing in which case
			// I don't care lol
			if mirror {
				//sprite.x *= -1
				sprite.image_angle *= -1
				sprite.image_xscale *= -1
			}
		
			sprite.image_yscale = cell[3] / 100
			sprite.image_alpha = cell[6] / 255
		
			// TODO: sprite blending
			//sprite.image_blend = cell[7]
		
			sprite.visible = true
		}
		else {
			sprite.visible = false	
		}
	}

	var num_timings = array_length(anim.timings)
	for(var i = 0; i < num_timings; i++) {
		var timing = anim.timings[i]
	
		// rpg_sprites.js: Sprite_Animation.prototype.processTimingData
		// once again modified
		if timing.frame == current_frame {
			var se = timing.se
			if se {
				var name = $"{se.name}"
				try {
					var sfx = rpg_get_sound_effect(se.name)
					audio_play_sound(sfx.sound, 50, false, se.volume / 100, 0, se.pitch / 100)	
				}
				catch(e) {
					show_debug_message(se)
					with(obj_controller) submit_error(e)
					
					// This looks nonsensical but this project triggers a garbage collection bug
					// in OMORI and this is a way to detect it. I'm not entirely sure what causes it
					// but in OMORI it happens if you play "EMS CHEESE" halfway, switch to anther animation
					// then very quickly switch back to EMS CHEESE. You may need to try it a few times.
					// Maybe it's the try-catch?
					if name != se.name {
						show_debug_message($"{name} {se.name}")
						with(obj_controller) {
							repeat(5) submit_message("!!! GC BUG DETECTED PLEASE RESTART THE PROGRAM !!!", c_orange)
						}
						instance_destroy()
						return
					}
				}
			}
			
			// Flash alpha is neutered to avoid getting flashbanged
			// when playing animations. Trust me, you probably want this
			var hide = false;
			var alpha = 0.75;
			var target = noone;
			switch timing.flashScope {
				case 0: break;                                    // None
				case 1: target = self.target; break;              // Target
				case 2: target = id; alpha = 0.5; break;          // Screen
				case 3: target = self.target; hide = true; break; // Hide (it's not a flash though...)
				default: show_debug_message($"Unsupported flash command: {timing}")
			}
			
			with (target) {
				if hide {
					hide_frames = timing.flashDuration
				}
				else {
					var color = timing.flashColor
					flash_frames = timing.flashDuration
					flash_max_frames = timing.flashDuration
					flash_color = make_color_rgb(color[0], color[1], color[2])
					flash_alpha = (color[3] / 255) * alpha	
				}
			}
		}
	}
	current_frame += remainder
}
else {
	step_flash = false
	step_hide = false	
}
current_frame += framerate / game_get_speed(gamespeed_fps)
