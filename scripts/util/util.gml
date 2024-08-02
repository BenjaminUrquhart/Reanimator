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