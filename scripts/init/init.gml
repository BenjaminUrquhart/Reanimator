rpg_clear_temp_files()


// Ask which game to inspect
ini_open(game_save_id + "history.ini")
var previous = ini_read_string("History", "previous", working_directory)
show_debug_message(previous)
var folder = get_open_filename_ext("Game.exe |*.exe", "Game.exe", previous, "Select game executable")
if folder == "" {
	game_end()
	return;
}

folder = file_get_folder(folder)
show_debug_message(folder)
if !rpg_init(folder) {
	game_end()
	return;
}

// It's probably safe to save this as the previous entry now
ini_write_string("History", "previous", folder)
ini_close()

window_set_caption($"Reanimator (Game: {global.data_system[$ "gameTitle"]})")

global.show_boxes = false
global.show_dummy = true

// Should already be 60 but just in case
game_set_speed(60, gamespeed_fps)
gpu_set_tex_filter(false)