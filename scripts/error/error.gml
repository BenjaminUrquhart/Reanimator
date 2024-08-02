function do_throw(msg) {
	throw {
		message: msg,
		stacktrace: debug_get_callstack()
	}
}

function expect(input, expected, err) {
	if input != expected {
		do_throw($"{err}: expected '{expected}' got '{input}'")	
	}
}