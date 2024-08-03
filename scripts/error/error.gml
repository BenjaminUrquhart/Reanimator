function do_throw(msg) {
	throw {
		message: msg,
		stacktrace: debug_get_callstack()
	}
}

function expect(input, expected, err) {
	assert(input == expected, $"{err}: expected '{expected}' got '{input}'")
}

function assert(value, err) {
	if !value {
		do_throw(err)	
	}
}