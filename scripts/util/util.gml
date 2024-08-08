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

function construct(index) {
	static _new = method_by_name("@@NewGMLObject@@")
	var args = array_create(argument_count, -1)
	for(var i = 0; i < argument_count; i++) {
		args[i] = argument[i]	
	}
	return script_execute_ext(_new, args)
}
// Feather enable GM1041