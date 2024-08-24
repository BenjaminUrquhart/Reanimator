#macro RPG_ASSET_CACHE global.__rpg_asset_cache__
#macro RPG_ASSET_CLEANUP_TS global.__rpg_asset_cleanup_ts__

#macro RPG_ASSET_CACHE_TIMEOUT 30

if !variable_global_exists("__rpg_asset_cache__")      RPG_ASSET_CACHE = {}
if !variable_global_exists("__rpg_asset_cleanup_ts__") {
	RPG_ASSET_CLEANUP_TS = time_source_create(time_source_game, 1, time_source_units_seconds, function() {
		var keys = struct_get_names(RPG_ASSET_CACHE)
		var len = array_length(keys)
		for(var i = 0; i < len; i++) {
			var key = keys[i]
			var entry = RPG_ASSET_CACHE[$ key]
			if entry.claimed() {
				entry.expires = RPG_ASSET_CACHE_TIMEOUT
			}
			else if entry.expires < 1 {
				if entry.cleanup() {
					show_debug_message($"Asset {key} removed from cache")
					struct_remove(RPG_ASSET_CACHE, key)	
				}
				else {
					show_debug_message($"Failed to remove asset {key} from cache")	
				}
			}
			else {
				entry.expires--	
			}
		}
	}, [], -1)
	time_source_start(RPG_ASSET_CLEANUP_TS)
}

// Asset caching stuff
function rpg_is_cached(name) {
	return variable_struct_exists(RPG_ASSET_CACHE, name)	
}

function rpg_get_cached_asset(name, func = undefined, args = undefined) {
	if !rpg_is_cached(name) {
		if is_method(func) || is_callable(func) {
			// if asset is missing from cache, use the provided
			// function to fetch it
			if !is_array(args) || array_length(args) == 0 {
				args = [name]
			}
			var asset = script_execute_ext(func, args)
			RPG_ASSET_CACHE[$ name] = {
				asset: asset,
				names: {},
				owners: ds_list_create(),
				expires: RPG_ASSET_CACHE_TIMEOUT,
				claimed: function() {
					// iterate the entire list instead of returning early
					// so we can remove destroyed instances
					var num = ds_list_size(owners)
					for(var j = 0; j < num; j++) {
						if !instance_exists(owners[| j]) {
							struct_remove(names, owners[| j])
							ds_list_delete(owners, j)
							num--
							j--
						}
					}
					return num > 0
				},
				cleanup: function() {
					if is_undefined(asset) {
						show_debug_message("cleanup() called on destroyed asset")
						return false
					}
					if is_struct(asset) && is_instanceof(asset, AudioSource) {
						if audio_is_playing(asset.sound) {
							show_debug_message($"Skipping sound asset {asset.path} (currently in use)")
							expires = max(3, ceil(RPG_ASSET_CACHE_TIMEOUT / 4))
							return false
						}
						else if !asset.free() {
							show_debug_message($"Failed to free sound {asset.path} but destroying asset anyway (LEAK)")
						}
					}
					else {
						switch asset_get_type(asset) {
							case asset_font:   font_delete(asset);   break;
							case asset_sprite: sprite_delete(asset); break;
							default: show_debug_message($"Unknown asset type {asset_get_type(asset)} but deleting asset anyway (LEAK)")
						}
					}
					ds_list_destroy(owners)
					names = undefined
					asset = undefined
					return true
				}
			}
		}
		else {
			do_throw($"{name} not in cache")	
		}
	}
	var entry = RPG_ASSET_CACHE[$ name]
	if variable_instance_exists(self, "id") {
		if ds_list_find_index(entry.owners, id) == -1 {
			ds_list_add(entry.owners, id)
			entry.names[$ id] = object_get_name(object_index)
		}
	}
	else {
		show_debug_message($"Asset {name} requested from source other than object")
	}
	entry.expires = RPG_ASSET_CACHE_TIMEOUT
	return entry.asset
}

// This may cause problems if another instance is running.
// To that, I say "simply don't do that"
// TODO: make it so you can do that
function rpg_clear_temp_files(force = false) {
	
	if force && (event_type != ev_other || event_number != ev_game_end) {
		do_throw("force clear only allowed from game end event")
		return
	}
	
	var used = {}
	if variable_global_exists("__rpg_asset_cache__") {
		var keys = struct_get_names(RPG_ASSET_CACHE)
		var num = array_length(keys)
	
		for(var i = 0; i < num; i++) {
			var asset = RPG_ASSET_CACHE[$ keys[i]].asset
			if is_instanceof(asset, AudioSource) && asset.asset.encrypted {
				used[$ asset.asset.path] = $"{asset.type}/{asset.name}"
			}
		}
	}
	var file = file_find_first(game_save_id + "*.tmp", fa_none)
	while file != "" {
		var tmp = game_save_id + file
		var free = is_undefined(used[$ tmp])
		if free || force {
			if force && !free {
				show_debug_message($"WARNING: temp file {tmp} in use but being removed anyway, this should only ever happen at shutdown!")
			}
			else {
				show_debug_message($"Removing temp file {tmp}")	
			}
			file_delete(tmp)
		}
		else {
			show_debug_message($"Temp file {tmp} in use by audio asset {used[$ tmp]}")
		}
		file = file_find_next()
	}
	file_find_close()
}