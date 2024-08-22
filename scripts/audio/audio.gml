enum AudioFormat {
	OGG,
	WAV
}

// I probably overengineered this but it works so I'm not touching it
function AudioSource(_type, _name) constructor {
	type = _type;
	name = _name;
	
	// TODO: does this need to be here
	// can just read it off the asset property
	path = RPG_GAME_BASE + "audio/" + type + "/" + name;
	asset = rpg_find_asset(RPG_GAME_BASE + "audio/" + type + "/" + name, true)
	
	show_debug_message($"loading: {path} {asset.path}")
	
	data = buffer_load(asset.path ?? path)
	
	var header = buffer_read_string(data, 4)
	
	// OggS
	if header == "OggS" {
		show_debug_message("format: ogg")
		
		format = AudioFormat.OGG	
		sound = audio_create_stream(asset.path ?? path)
		buffer_delete(data)
		data = -1
	}
	// RIFF
	else if header == "RIFF" {
		show_debug_message("format: wav")
		
		format = AudioFormat.WAV
		
		// Why did I do this I don't even know if RPGMaker supports WAV.
		// Anyway.
		// Gotta parse the WAV a bit here to get some metadata.
		// https://isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/s02_01_p05.html
		expect(buffer_read(data, buffer_u32), buffer_get_size(data) - 8, "Bad WAV filesize")
		expect(buffer_read_string(data, 4), "WAVE", "Bad WAV header")
		expect(buffer_read_string(data, 4), "fmt ", "Bad WAV header")
		
		
		var fmt_size = buffer_read(data, buffer_u32)
		expect(buffer_read(data, buffer_u16), 1, "Bad WAV type format")
		var stereo = buffer_read(data, buffer_u16) == 2
		var frequency = buffer_read(data, buffer_u32)
		var rate = buffer_read(data, buffer_u32)
		var alignment = buffer_read(data, buffer_u16)
		var bps = buffer_read(data, buffer_u16)
		
		show_debug_message($"stereo: {stereo}\nfrequency: {frequency}\nrate: {rate}\nalignment: {alignment}\nbps: {bps}")
		
		
		expect(buffer_read_string(data, 4), "data", "Bad WAV format section")
		var length = buffer_read(data, buffer_u32)
		var offset = buffer_tell(data)
		buffer_seek(data, buffer_seek_start, 0)
		
		// buffer_load gives us a grow buffer which we can't use
		var audio_data = buffer_create(length, buffer_fixed, 1)
		buffer_copy(data, offset, length, audio_data, 0)
		buffer_delete(data)
		data = audio_data
		
		sound = audio_create_buffer_sound(
			data,
			bps == 8 ? buffer_u8 : buffer_s16,
			frequency,
			0,
			length,
			stereo ? audio_stereo : audio_mono
		)
	}
	else {
		// There's other audio formats RPGMaker MV supports iirc
		// but GMS only supports OGG and WAV at runtime
		buffer_seek(data, buffer_seek_start, 0)
		var header_int = buffer_read(data, buffer_u32)
		buffer_delete(data)
		do_throw($"Unknown audio header {header} ({dec_to_hex(header_int)})")
	}
	
	if !audio_exists(sound) {
		if buffer_exists(data) {
			buffer_delete(data)	
		}
		do_throw($"Failed to create sound from asset {path}")
	}
	
	// debug purposes
	static play = function() {
		assert(audio_exists(sound), $"audio use after free: {type}/{name}")
		if format == AudioFormat.WAV {
			assert(buffer_exists(data), $"data buffer freed for WAV audio: {type}/{name}")	
		}
		return audio_play_sound(sound, 50, false)
	}
	
	static free = function() {
		if !audio_exists(sound) {
			return false
		}
		if format == AudioFormat.OGG {
			if !audio_destroy_stream(sound)	{
				return false
			}
		}
		else {
			audio_free_buffer_sound(sound)
			buffer_delete(data)
		}
		if asset.encrypted && asset.path {
			// Deletes the temporary file, not the 
			// obfuscated one from the game
			
			// Sanity check
			assert(!string_pos(RPG_GAME_BASE, asset.path), $"Temporary file {asset.path} is within the game folder")
			file_delete(asset.path)	
		}
		return true
	}
	
}

function SoundEffect(name) : AudioSource("se", name) constructor {}
function MusicEffect(name) : AudioSource("me", name) constructor {}
function BackgroundMusic(name) : AudioSource("bgm", name) constructor {}
function BackgroundSound(name) : AudioSource("bgs", name) constructor {}