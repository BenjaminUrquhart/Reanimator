function buffer_read_string(buff, length) {
	var out = "";
	for(var i = 0; i < length; i++) {
		out += chr(buffer_read(buff, buffer_u8))
	}
	return out;
}

function json_load(filename) {
	assert(file_exists(filename), $"File not found: {filename}")
	var file = buffer_load(filename)
	var json = buffer_read(file, buffer_text)
	buffer_delete(file)
	return json_parse(json);
}

/// @func   dec_to_hex(dec, len)
///
/// @desc   Returns a given value as a string of hexadecimal digits.
///         Hexadecimal strings can be padded to a minimum length.
///         Note: If the given value is negative, it will
///         be converted using its two's complement form.
///
/// @param  {real}      dec         integer
/// @param  {real}      [len=1]     minimum number of digits
///
/// @return {string}    hexadecimal digits
///
/// GMLscripts.com/license

function dec_to_hex(dec, len = 1) 
{
    var hex = "";

    if (dec < 0) {
        len = max(len, ceil(logn(16, 2 * abs(dec))));
    }

    var dig = "0123456789ABCDEF";
    while (len-- || dec) {
        hex = string_char_at(dig, (dec & $F) + 1) + hex;
        dec = dec >> 4;
    }

    return hex;
}