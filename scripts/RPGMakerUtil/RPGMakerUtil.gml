#macro RPG_GAME_BASE global.__rpg_game_path__
#macro RPG_ASSET_CACHE global.__rpg_asset_cache__
#macro RPG_ASSET_CACHE_AGES global.__rpg_asset_cache_ages__
#macro RPG_ASSET_KEY global.__rpg_asset_key__
#macro RPG_USE_DUMMY_IMAGE global.__rpg_use_dummy_image__
#macro RPG_ASSET_CLEANUP_TS global.__rpg_asset_cleanup_ts__

#macro RPG_ASSET_CACHE_TIMEOUT 60

// Forums say this can be changed
// I cannot find the option in the IDE
// or in System.json so uh yeah
#macro RPG_WINDOW_WIDTH 816
#macro RPG_WINDOW_HEIGHT 624


if !variable_global_exists("__rpg_use_dummy_image__")  RPG_USE_DUMMY_IMAGE = false
if !variable_global_exists("__rpg_asset_cache__")      RPG_ASSET_CACHE = {}
if !variable_global_exists("__rpg_asset_key__")        RPG_ASSET_KEY = undefined
if !variable_global_exists("__rpg_asset_cache_ages__") RPG_ASSET_CACHE_AGES = {}
if !variable_global_exists("__rpg_asset_cleanup_ts__") {
	RPG_ASSET_CLEANUP_TS = time_source_create(time_source_game, 1, time_source_units_seconds, function() {
		// Assets without an age are kept forever
		// TODO: make this smarter 
		// (track instance ids and only unload assets once all corresponding animators are destroyed)
		var keys = struct_get_names(RPG_ASSET_CACHE_AGES)
		var len = array_length(keys)
		for(var i = 0; i < len; i++) {
			var key = keys[i]
			if RPG_ASSET_CACHE_AGES[$ key] < 1 {
				var asset = RPG_ASSET_CACHE[$ key]
				if is_instanceof(asset, AudioSource) {
					if audio_is_playing(asset.sound) {
						show_debug_message($"Skipping sound asset {asset.path} (currently in use)")
						RPG_ASSET_CACHE_AGES[$ key] = max(3, ceil(RPG_ASSET_CACHE_TIMEOUT / 4))
						continue
					}
					else if !asset.free() {
						show_debug_message($"Failed to free sound asset {asset.path}")	
					}
				}
				else {
					sprite_delete(asset)	
				}
				show_debug_message($"Asset {key} removed from cache")
				struct_remove(RPG_ASSET_CACHE_AGES, key)
				struct_remove(RPG_ASSET_CACHE, key)
			}
			else {
				RPG_ASSET_CACHE_AGES[$ key]--	
			}
		}
	}, [], -1)
	time_source_start(RPG_ASSET_CLEANUP_TS)
}

// Set up some globals
// might move cache stuff here idk
function rpg_init(game, index = "www") {
	RPG_GAME_BASE = game + "/" + index + "/"
	
	if !file_exists(RPG_GAME_BASE + "data/System.json") {
		// OMORI moment
		if file_exists(RPG_GAME_BASE + "data/System.KEL") {
			show_message("You must decrypt OMORI before using this tool on it")
			return false
		}
		
		do_throw($"Invalid game path: {game}")
	}
	
	global.data_system = rpg_read_datafile("System.json")
	RPG_ASSET_KEY = global.data_system[$ "encryptionKey"]
	
	if !is_undefined(RPG_ASSET_KEY) {
		expect(string_length(RPG_ASSET_KEY), 32, "Invalid asset key length")
	}
	
	global.data_animations = rpg_read_datafile("Animations.json")
	global.data_enemies = rpg_read_datafile("Enemies.json")
	return true
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
			RPG_ASSET_CACHE[$ name] = script_execute_ext(func, args)
		}
		else {
			do_throw($"{name} not in cache")	
		}
	}
	RPG_ASSET_CACHE_AGES[$ name] = RPG_ASSET_CACHE_TIMEOUT
	return RPG_ASSET_CACHE[$ name]
}

function rpg_claim_assets(names) {
	var len = array_length(names)
	for(var i = 0; i < len; i++) {
		var key = names[i]
		if string_length(key) == 0 continue
		if struct_exists(RPG_ASSET_CACHE_AGES, key) {
			show_debug_message($"{key} held")
			struct_remove(RPG_ASSET_CACHE_AGES, key)	
		}
		else if struct_exists(RPG_ASSET_CACHE, key) {
			show_debug_message($"{key} held but currently not pending removal from cache")
		}
		else {
			show_debug_message($"{key} held but currently not in cache")
		}
	}
}

function rpg_release_assets(names) {
	var len = array_length(names)
	for(var i = 0; i < len; i++) {
		var key = names[i]
		if string_length(key) == 0 continue
		if struct_exists(RPG_ASSET_CACHE, key) {
			show_debug_message($"{key} released")
			RPG_ASSET_CACHE_AGES[$ key] = RPG_ASSET_CACHE_TIMEOUT
		}
		else {
			show_debug_message($"{key} released but not currently in cache")
		}
	}
}

// Is this needed
function rpg_cache_asset(name, asset) {
	if rpg_is_cached(name) {
		do_throw($"{name} already in cache")	
	}
	RPG_ASSET_CACHE[$ name] = asset
}


// Helper to read game jsons
function rpg_read_datafile(filename) {
	return json_load(RPG_GAME_BASE + "data/" + filename)
}


// Basically a wrapper around rpg_load_image with
// special handling for the empty string.
// It just makes the animator code nicer.
function rpg_get_animation_sheet(name) {
	if name == "" {
		return {
			sheet: -1,
			key: ""
		}
	}
	
	var key = RPG_GAME_BASE + "img/animations/" + name
	return {
		sheet: rpg_load_image(key),
		key: key
	}
}

// Audio stuff
// Also see the "audio" script
function rpg_get_sound_effect(name) {
	return rpg_get_cached_asset("se/" + name, construct, [SoundEffect, name]);
}

function rpg_get_music_effect(name) {
	return rpg_get_cached_asset("me/" + name, construct, [MusicEffect, name]);
}

function rpg_get_background_effect(name) {
	return rpg_get_cached_asset("bgs/" + name, construct, [BackgroundSound, name]);
}

function rpg_get_background_music(name) {
	return rpg_get_cached_asset("bgm/" + name, construct, [BackgroundMusic, name]);
}

// Sprites and related
function rpg_load_image(filepath) {
	return rpg_get_cached_asset(filepath, function(path) {
		var result;
		
		try {
			result = rpg_find_asset(path, true)
		}
		catch(e) {
			if RPG_USE_DUMMY_IMAGE {
				return spr_missing
			}
			show_debug_message(e.message)
			array_foreach(e.stacktrace, show_debug_message)
			throw e
		}
		
		var sprite = sprite_add(result.path, 1, false, false, 0, 0)
		if !sprite_exists(sprite) {
			do_throw($"Failed to load {path}")	
		}
		return sprite;
	});
}

// Enemy sprites can be stored in img/enemies or img/sv_enemies
// This figures out which one and loads the sprite
function rpg_enemy_find_sprite(enemy) {
	var base = RPG_GAME_BASE + "img/enemies/" + actor
	var paths = file_find_with_ext(base)
	if array_length(paths) {
		return base
	}
	
	base = RPG_GAME_BASE + "img/sv_enemies/" + actor
	paths = file_find_with_ext(base)
	if array_length(paths) {
		return base
	}
	
	do_throw($"No enemy sprite found for {actor}")
}

// Gets the actual path, optionally demangling it so it can actually be used
function rpg_find_asset(filepath, decrypt = false, asset = undefined) {
	
	var tempfile = $"{game_save_id}{sha1_string_utf8(filepath)}.tmp"
	// Shortcut
	/*
	if file_exists(filepath) {
		show_debug_message($"Found decrypted file on disk {filepath} -> {tempfile}")
		return {
			encrypted: true,
			asset: asset ?? filepath,
			path: tempfile
		}
	}*/
	
	// Usually the extension is missing, so we need to find it
	if !file_exists(filepath) {
		var paths = file_find_with_ext(filepath)
		if !array_length(paths) {
			do_throw($"Asset not found: {filepath}")
		}
		var len = array_length(paths)
		for(var i = 0; i < len; i++) {
			//show_debug_message(paths[i])
			try {
				return rpg_find_asset(paths[i], decrypt, filepath)
			}
			catch(e) {
				show_debug_message(e)	
			}
		}
		do_throw($"No valid asset files found: {filepath}")
	}
	
	asset ??= filepath
	
	// Check for the RPGMaker MV "encryption" header
	var data = buffer_load(filepath)
	var header = buffer_read(data, buffer_u64)
	//show_debug_message($"0x{dec_to_hex(header)} - 0x564D475052")
	// RPGMV (+3 null bytes)
	if header == 0x564D475052 {
		if decrypt {
			if is_undefined(RPG_ASSET_KEY) {
				buffer_delete(data)
				do_throw($"Asset is encrypted but no key was found: {filepath}")
				return;
			}
		
			// Trim RPGMaker header
			var tmp = buffer_create(buffer_get_size(data) - 16, buffer_fixed, 1)
			buffer_seek(data, buffer_seek_start, 0)
			buffer_copy(data, 16, buffer_get_size(tmp), tmp, 0)
			buffer_delete(data)
			data = tmp
		
			// Nice "encryption" lol
			for(var i = 0; i < 16; i++) {
				var byte = buffer_read(data, buffer_u8) ^ int64(ptr(string_copy(RPG_ASSET_KEY, i * 2 + 1, 2)))
				buffer_seek(data, buffer_seek_relative, -1)
				buffer_write(data, buffer_u8, byte)
			}
			
			// Streamed audio requires the file to exist on disk
			// so we write "decrypted" files back to disk temporarily
			// These are cleaned up on next launch
			buffer_seek(tmp, buffer_seek_start, 0)
			buffer_save(tmp, tempfile)	
			buffer_delete(tmp)
			return {
				encrypted: true,
				asset: asset,
				path: tempfile
			}
		}
		return {
			encrypted: true,
			asset: asset,
			path: undefined
		}

	}
	return {
		encrypted: false,
		asset: asset,
		path: filepath
	}
}