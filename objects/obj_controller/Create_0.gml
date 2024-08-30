#macro TITLE { name: 
#macro ITEMS , names: 
#macro CALLBACK , submit: 
#macro END }

player = noone
message_queue = ds_list_create()

menu = 0

submit_error = function(e) {
		show_debug_message(e.message)
		show_debug_message(e.stacktrace)
		submit_message($"Internal error:\n{e.message}", c_red)
		//debug_event("ResourceCounts")
}

submit_message = function(msg, color = c_white) {
	ds_list_add(message_queue, {
		message: msg,
		color: color,
		timer: 150,
		alpha: 1
	})
}

target = noone

create_target = function(index = -1) {
	
	static enemy = -1
	
	try {
		if enemy == -1 {
			var first_valid = -1
			var name = global.data_system[$ "battlerName"]
			var len = array_length(global.data_enemies)
			for(var i = 0; i < len; i++) {
				if global.data_enemies[i] {
					if first_valid == -1 {
						first_valid = i	
					}
				
					if global.data_enemies[i].battlerName == name {
						enemy = i
						break
					}
				}
			}
			if enemy == -1 {
				if first_valid == -1 {
					show_debug_message("Failed to find any valid enemies")
					if index == -1 return
				}
				else {
					enemy = first_valid	
				}
			}
		}
		
		target = instance_create_layer(room_width / 5 + (room_width * 0.8) / 2, room_height / 2, "TestDummy", obj_enemy_animator, { enemy: global.data_enemies[index == -1 ? enemy : index], list_index: index == -1 ? enemy : index })	
	}
	catch(e) {
		submit_error(e)
		target = noone
	}	
}

create_target()

var mapper = function(obj) {
	return obj ? (obj.name == "" ? "---" : obj.name) : "<null>";
}

var anim_names = array_map(global.data_animations, mapper)
var anim_callback = function(selector, index) {
	if global.data_animations[index] {
		audio_stop_all()
		
		with(target) {
			flash_frames = 0
			hide_frames = 0
		}
	
		if instance_exists(player) && player.anim.id == index {
			player.reset()
		}
		else {
			instance_destroy(player)
		
			// TODO: better handing, maybe pause the animation
			// if something goes wrong part way
			try {
				player = instance_create_layer(0, 0, "Flash", obj_animation_player, { anim: global.data_animations[index], target: target })	
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
		
		with(target) {
			flash_frames = 0
			hide_frames = 0
		}
		
		try {
			with(obj_enemy_animator) instance_destroy()
			player = instance_create_layer(room_width / 5 + (room_width * 0.8) / 2, room_height / 2, "TestDummy", obj_enemy_animator, { enemy: global.data_enemies[index], list_index: index })
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
	TITLE "Animations" ITEMS anim_names CALLBACK anim_callback END,
	TITLE "Enemies" ITEMS enemy_names CALLBACK enemy_callback END
]

menu_count = array_length(menus)
menu_positions = array_create(menu_count, 1)

selector = instance_create_layer(0, 0, "Controller", obj_selector, menus[0])
selector.index = 1