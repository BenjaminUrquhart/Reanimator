enum SVActorState {
	IDLE,
	STABBING,
	ESCAPE,
	
	READY_PHYS,
	SWINGING,
	VICTORY,
	
	READY_SPEC,
	SHOOTING,
	DANGER,
	
	GUARD,
	SKILL_PHYS,
	ABNORMAL,
	
	DAMAGE,
	SKILL_SPEC,
	SLEEPING,
	
	EVADE,
	USE,
	DEAD,
	
	LAST
}


if is_undefined(enemy) {
	do_throw("No enemy provided")
	instance_destroy(id, false)
	return;
}

tags = rpg_ext_parse_notetags(enemy.note)
show_debug_message(tags)

is_sv_actor = struct_exists(tags, "Sideview Battler")

if is_sv_actor {
	actor = tags[$ "Sideview Battler"]
	timer = tags[$ "Sideview Battler Speed"] ?? 12
	sheet = rpg_load_image(RPG_GAME_BASE + "img/sv_actors/" + actor)
}
else {
	timer = 12
	actor =  enemy.battlerName
	sheet = rpg_load_image(RPG_GAME_BASE + "img/enemies/" + actor)	
}

surface = -1
previous_sheet = sheet

previous_state = -1
state = SVActorState.IDLE

started = !is_sv_actor

index = 0

dir = 1

draw_state = function(dx, dy, state = self.state, index = self.index) {
	if !is_sv_actor {
		do_throw("Not an sv_actor")	
	}
	var ww = sprite_get_width(sheet) / 9
	var hh = sprite_get_height(sheet) / 6
	var xx = ww * ((state % 3) * 3 + floor(index))
	var yy = hh * floor(state / 3)
	draw_sprite_part(sheet, 0, xx, yy, ww, hh, dx, dy)
}