// do our best to unload all assets so temp files can be cleared safely
audio_stop_all()
with(all) instance_destroy()
var keys = struct_get_names(RPG_ASSET_CACHE)
var num = array_length(keys)
for(var i = 0; i < num; i++) {
	if !RPG_ASSET_CACHE[$ keys[i]].cleanup() {
		show_debug_message($"Cleanup failed for asset {keys[i]}")	
	}
	struct_remove(RPG_ASSET_CACHE, keys[i])
}

rpg_clear_temp_files(true)
ds_list_destroy(message_queue)