# Default callbacks.
# Mawk must always define all callbacks.
# Gawk and busybox awk must define callbacks when STREAM=1 only.
# More info in FAQ.md#5.

# cb_parse_array_empty - parse an empty JSON array.
# Called in JSON.awk main loop when STREAM=0 only.
# This example returns the standard representation of an empty array.
function cb_parse_array_empty(jpath) {

#	print "parse_array_empty("jpath")" >"/dev/stderr"
	return "[]"
}

# cb_parse_object_empty - parse an empty JSON object.
# Called in JSON.awk main loop when STREAM=0 only.
# This example returns the standard representation of an empty object.
function cb_parse_object_empty(jpath) {

#	print "parse_object_empty("jpath")" >"/dev/stderr"
	return "{}"
}

# cb_parse_array_enter - begin parsing an array.
# Called in JSON.awk main loop when STREAM=0 only.
# Use this function to initialize or output other values involved in
# processing each new JSON array.
function cb_parse_array_enter(jpath) {

#	print "cb_parse_array_enter("jpath") token("TOKEN")" >"/dev/stderr"
	if ("" != jpath)
		;
}

# cb_parse_array_exit - end parsing an array.
# Called in JSON.awk main loop when STREAM=0 only.
# If status == 0 then global CB_VALUE holds the JSON text of the parsed array.
function cb_parse_array_exit(jpath, status) {

#	print "cb_parse_array_exit("jpath") status("status") token("TOKEN") value("CB_VALUE")" >"/dev/stderr"
}

# cb_parse_object_enter - begin parsing an object.
# Called in JSON.awk main loop when STREAM=0 only.
# Use this function to initialize or output other values involved in
# processing each new JSON object.
function cb_parse_object_enter(jpath) {

#	print "cb_parse_object_enter("jpath") token("TOKEN")" >"/dev/stderr"
	if ("" != jpath)
		;
}

# cb_parse_object_exit - end parsing an object.
# Called in JSON.awk main loop when STREAM=0 only.
# If status == 0 then global CB_VALUE holds the JSON text of the parsed object.
function cb_parse_object_exit(jpath, status) {

#	print "cb_parse_object_exit("jpath") status("status") token("TOKEN") value("CB_VALUE")" >"/dev/stderr"
}

# cb_append_jpath_component - format jpath components
# Called in JSON.awk main loop when STREAM=0 only.
# This example formats jpaths exactly as JSON.awk does when STREAM=1.
function cb_append_jpath_component (jpath, component) {
	# if it is an array index, make it 1-indexed
	if (match(component, /^[0-9]+$/))
		component++;
	if (component == "") return jpath
	gsub(/^"|"$/, "", component)
	if (jpath == "") return "\"" component "\""
	gsub(/^"|"$/, "", jpath)
	return "\"" jpath SUBSEP component "\""
}

# cb_append_jpath_value - format a jpath / value pair
# Called in JSON.awk main loop when STREAM=0 only.
# This example formats the jpath / value pair exactly as JSON.awk does when
# STREAM=1.
function cb_append_jpath_value (jpath, value) {

#	print "cb_append_jpath_value("jpath") ("jpath") value("value")" >"/dev/stderr"
	return sprintf("%s\t%s", jpath, value)
}

# cb_jpaths - process cb_append_jpath_value outputs
# Called in JSON.awk main loop when STREAM=0 only.
# This example illustrates printing jpaths to stdout as JSON.awk does when STREAM=1.
# See also cb_parse_array_enter and cb_parse_object_enter.
function cb_jpaths (ary, size,   i) {
	# Print ary - array of size jpaths and their values.
	for(i=1; i <= size; i++) {
		print ary[i]
	}

	# Print a newline for newline-delimited JSON
	print ""
}

# cb_fails - process all error messages at once after parsing
# has completed. Called in JSON.awk END action when STREAM=0 only.
# This example illustrates printing parsing errors to stdout,
function cb_fails (ary, size,   k) {
}

# cb_fail1 - process a single parse error as soon as it is
# encountered.  Called in JSON.awk main loop when STREAM=0 only.
# Return non-zero to let JSON.awk also print the message to stderr.
# This example illustrates printing the error message to stdout only.
function cb_fail1 (message) {
	return 1
}
