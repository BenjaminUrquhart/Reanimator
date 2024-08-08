#macro construct global.__new_gml_object__

function file_get_folder(path) {
	var index = string_length(path)
	var byte = -1
	while index > 0 && byte != ord("\\") && byte != ord("/") {
		byte = string_byte_at(path, index--)	
	}

	if index > 0 {
		return string_copy(path, 0, index)
	}
	return path;
}

// It's cursed code time
// Feather ignore GM1041
function method_by_name(name) {
	static mappings = ds_map_create()
	static size = 0
	
	if !ds_map_exists(mappings, name) {
		var func_name
		do {
			func_name = script_get_name(size)
			if func_name == name {
				mappings[? func_name] = size
				size++
				return size - 1
			}
			size++
		} until(func_name == "<undefined>")
		return -1
	}
	
	return mappings[? name]
}
// Feather enable GM1041

// This was originally a wrapper function then I went to bed
// and remembered I can just do this instead.
if !variable_global_exists("__new_gml_object__") construct = method_by_name("@@NewGMLObject@@")