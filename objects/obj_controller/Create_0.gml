#macro ITEMS { names: 
#macro CALLBACK , submit: 
#macro END }

player = noone
error_text = ""

menu = 0

submit_error = function(e) {
		show_debug_message(e.message)
		show_debug_message(e.stacktrace)
		error_text = $"Error playing animation:\n{e.message}"
}

var mapper = function(obj) {
	return obj ? (obj.name == "" ? "---" : obj.name) : "<null>";
}

var anim_names = array_map(global.data_animations, mapper)
var anim_callback = function(selector, index) {
	if global.data_animations[index] {
		audio_stop_all()
	
		error_text = ""
		if instance_exists(player) && player.anim.id == index {
			player.reset()
		}
		else {
			instance_destroy(player)
		
			// TODO: better handing, maybe pause the animation
			// if something goes wrong part way
			try {
				player = instance_create_layer(0, 0, "Flash", obj_animation_player, { anim: global.data_animations[index] })	
			}
			catch(e) {
				submit_error(e)
				with(obj_animation_player) {
					// sprites don't exist at this stage
					instance_destroy(id, false)	
				}
			}
		}
	}
}

var enemy_names = array_map(global.data_enemies, mapper)
var enemy_callback = function(selector, index) {
	if global.data_enemies[index] {
		error_text = ""
		
		try {
			with(obj_enemy_animator) {
				instance_destroy()	
			}
			instance_create_layer(room_width / 5 + (room_width * 0.8) / 2, room_height / 2, "Sprites", obj_enemy_animator, { enemy: global.data_enemies[index], controls_locked: true })
		}
		catch(e) {
			submit_error(e)
			with(obj_enemy_animator) {
				instance_destroy()
			}
		}
	}
}

menus = [
	ITEMS anim_names CALLBACK anim_callback END,
	ITEMS enemy_names CALLBACK enemy_callback END
]

menu_count = array_length(menus)

selector = instance_create_layer(0, 0, "Controller", obj_selector, menus[0])