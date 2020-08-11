#!/bin/sh

set -eu

name=`basename $0`

usage() {
	echo "usage: $name [-v var=value] [-f progfile | 'prog'] [file]" >&2
	exit 1
}

p=
prog=
while getopts :v:f: opt; do
	case $opt in
	f) prog="$prog`cat "$OPTARG"`"; p=1 ;;
	v) ;;
	?) usage
	esac
done

i=0
skip=
f=
file=
for arg do
	i=$((i+1))
	shift
	# Skip -f options
	if [ "$i" -lt "$OPTIND" ]; then
		if [ "$skip" ]; then skip=; continue; fi
		# If starts with -f
		if [ "$arg" != "${arg#-f}" ]; then
			if [ "$arg" = "-f" ]; then skip=1; fi
			continue
		fi
	# Get prog and file
	else
		if [ ! "$p" ]; then prog=$arg; p=1
		elif [ ! "$f" ]; then file=$arg; f=1
		else usage; fi
		continue
	fi
	set -- "$@" "$arg"
done

if [ ! "$p" ]; then usage; fi
if [ ! "$f" ]; then file=-; fi

pre='
BEGIN { RS=""; FS="\n"; JSON="\1"; TYPE="\2" }
function keys(ks, o, n, a, i) {
	# differentiate between the root object and an empty root key
	# if the root object
	if (o == "" && o == 0) {
		# if object
		if ("\3" in _) {
			n = split(_["\3"], a, "\037")
			while (++i <= n) ks[a[i]] = a[i]
		# if array
		} else {
			n = _["length"]
			while (++i <= _["length"]) ks[i] = i
		}
	}
	else {
		# if object
		if ((o SUBSEP "\3") in _) {
			n = split(_[o,"\3"], a, "\037")
			while (++i <= n) ks[a[i]] = o SUBSEP a[i]
		# if array
		} else {
			n = _[o,"length"]
			while (++i <= n) ks[i] = o SUBSEP i
		}
	}
	return n
}
function __jawk(i, kv, key, value, raw_value, type, arg, cmd, ret, j) {
	for (i = 1; i <= NF; i++) {
		split($i, kv, "\t")
		# remove surrounding quotes
		key = substr(kv[1], 2, length(kv[1]) - 2)
		value = kv[2]
		raw_value = value
		# if string
		if (match(value, /^"/)) {
			# remove surrounding quotes
			value = substr(value, 2, length(value) - 2)
			# check if it needs escaping
			if (match(value, /\\/)) {
				# unescape common characters
				gsub(/\\"/, "\"", value)
				gsub(/\\n/, "\n", value)
				# if still needs escaping, fallback to printf
				if (match(value, /\\/)) {
					arg = raw_value
					# double up backslashes for printf
					gsub(/\\/, "\\\\", arg)
					# undo for quotes
					gsub(/\\"/, "\"", arg)
					gsub(/`/, "\\`", arg)
					gsub(/\$/, "\\$", arg)
					cmd="printf %b "arg
					value=""
					# RS needs to be reset for getline to
					# handle blank lines propertly
					RS="\n"
					while (ret = cmd | getline v) {
						if (ret == -1)
							exit 1
						++j
						if (j == 1)
							value = v
						else
							value = value "\n" v
					}
					close(cmd)
					RS=""
					# if had trailing newline, add it
					if (match(raw_value, /(^|[^\\])(\\\\)*\\n"$/))
						value = value "\n"
				}
			}
			type = "string"
		}
		# if object
		else if (match(value, /^\{/)) {
			value = key
			type = "object"
		}
		# if array
		else if (match(value, /^\[/)) {
			value = key
			type = "array"
		}
		else if (value == "true") {
			value = 1
			type = "boolean"
		}
		else if (value == "false") {
			value = 0
			type = "boolean"
		}
		else if (value == "null") {
			value = ""
			type = "null"
		} else {
			type = "number"
		}
		# if not the root object
		if (kv[1]) {
			_[key] = value
			_[key,JSON] = raw_value
			_[key,TYPE] = type
		} else {
			if (type != "array" && type != "object")
				_[0] = value;
			_[JSON] = raw_value
			_[TYPE] = type
		}
	}
}
{ __jawk() }
'

parser="`cat JSON.awk`"

awk -v BRIEF=0 -v KEYS="\3" "$parser" "$file" | awk "$@" "$pre""$prog"
