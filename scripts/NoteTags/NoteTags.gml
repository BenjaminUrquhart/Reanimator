// Regex when
function rpg_ext_parse_notetags(notes) {
	var len = string_length(notes)
	var index = 1
	
	var value;
	var tags = {}
	var duplicate = {}
	while index < len {
		if string_char_at(notes, index) == "<" {
			var tag = __read_note_tag(notes, index, len)
			var pos = string_pos(": ", tag.text)
			
			index += tag.size + 2
			
			// tag data is stored within the tag itself
			// example: <Sideview Battler: enemy>
			if pos > 0 {
				value = string_delete(tag.text, 0, pos + 1)
				tag.text = string_copy(tag.text, 0, pos - 1)
			}
			// data is stored after the tag, most likely with
			// a closing tag to signal the end of it
			// (this parser doesn't enforce closing tags)
			//
			// example:
			// <Sideview Battler Motion>
			// Index: 0
			// Loop
			// </Sideview Battler Motion>
			else {
				var start = index;
				while string_char_at(notes, index) != "<" && index <= len {
					index++
				}
				var closing = undefined
				if string_char_at(notes, index + 1) == "/" {
					closing = __read_note_tag(notes, index, len)
					if string_delete(closing.text, 0, 1) == tag.text {
						show_debug_message($"Found closing tag <{closing.text}>")
					}
					else {
						show_debug_message($"Warning: mismatched closing tag, expected </{tag.text}> got <{closing.text}>")	
					}
				}
				index--
				value = string_split(string_copy(notes, start, index - start), "\n", true)
				
				// Most likely a toggle tag
				// where it simply existing is
				// all that's important
				if array_length(value) < 1 {
					value = true	
				}
				if !is_undefined(closing) {
					index += closing.size + 2	
				}
			}
			show_debug_message($"{tag.text} -> {value}")
			if struct_exists(tags, tag.text) && !duplicate[$ tag.text] {
				tags[$ tag.text] = [tags[$ tag.text]]
				duplicate[$ tag.text] = true
			}
			if duplicate[$ tag.text] {
				array_push(tags[$ tag.text], value)
			}
			else {
				tags[$ tag.text] = value
			}
		}
		else {
			index++	
		}
	}
	return tags
}

function __read_note_tag(notes, start, note_len) {
	var index = start
	while string_char_at(notes, index) != ">" && index <= note_len {
		index++
	}
	if index > note_len {
		do_throw($"EOF when reading tag at {start}")	
	}
	var size = index - start - 1
	return {
		size: size,
		text: string_copy(notes, start + 1, size)
	}
}