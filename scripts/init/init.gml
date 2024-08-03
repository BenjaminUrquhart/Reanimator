// This may cause problems if another instance is running.
// To that, I say "simply don't do that"
// TODO: fix later
var file = file_find_first(game_save_id + "*.tmp", fa_none)
while file != "" {
	file_delete(game_save_id + file)
	file = file_find_next()
}
file_find_close() 


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

//rpg_init("C:\\Program Files (x86)\\Steam\\steamapps\\common\\In Stars And Time")
//rpg_init("C:\\Program Files (x86)\\Steam\\steamapps\\common\\OMORI", "www_playtest")

game_set_speed(15, gamespeed_fps)