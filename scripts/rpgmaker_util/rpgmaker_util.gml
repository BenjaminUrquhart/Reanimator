#macro RPG_GAME_BASE global.__rpg_game_path__
#macro RPG_ASSET_CACHE global.__rpg_asset_cache__
#macro RPG_ASSET_KEY global.__rpg_asset_key__


if !variable_global_exists("__rpg_asset_cache__") RPG_ASSET_CACHE = {}
if !variable_global_exists("__rpg_asset_key__")   RPG_ASSET_KEY = undefined

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
	return RPG_ASSET_CACHE[$ name]
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
		return -1;
	}
	
	return rpg_load_image(RPG_GAME_BASE + "img/animations/" + name)
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
		var result = rpg_find_asset(path, true)
		var sprite = sprite_add(result.path, 1, false, false, 0, 0)
		if !sprite_exists(sprite) {
			do_throw($"Failed to load {path}")	
		}
		return sprite;
	});
}

// Gets the actual path, optionally demangling it so it can actually be used
function rpg_find_asset(filepath, decrypt = false, asset = undefined) {
	
	// Usually the extension is missing, so we need to find it
	if !file_exists(filepath) {
		var folder = file_get_folder(filepath)
		var file = file_find_first(filepath + ".*", fa_none)
		while file != "" {
			show_debug_message(file)
			try {
				var res = rpg_find_asset(folder + "/" + file, decrypt, filepath)
				file_find_close()
				return res;
			}
			catch(e) {
				show_debug_message(e)
			}
			file = file_find_next()
		}
		file_find_close()
		do_throw($"Asset not found: {filepath}")
	}
	
	asset ??= filepath
	
	// Check for the RPGMaker MV "encryption" header
	var data = buffer_load(filepath)
	var header = buffer_read(data, buffer_u64)
	show_debug_message($"0x{dec_to_hex(header)} - 0x564D475052")
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
			var tempfile = game_save_id + $"{sha1_string_utf8(filepath)}.tmp"
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