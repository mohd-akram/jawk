#!/bin/sh

set -eu

name=`basename $0`

usage() {
	echo >&2 "usage: $name [-v var=value] [-f progfile | 'prog'] [file ...]"
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
files=
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
		else
			if [ ! "$f" ]; then files="$arg"
			else files=$(printf '%s\t%s' "$files" "$arg"); fi
			f=$((f+1))
		fi
		continue
	fi
	set -- "$@" "$arg"
done

if [ ! "$p" ]; then usage; fi

jawk=$(cat jawk.awk)

ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
CHAR='[^[:cntrl:]"\\]'
STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
KEYWORD='null|false|true'
JSON="$STRING|$NUMBER|$KEYWORD|[][{}:,]|[^[:space:]]"

prog="$jawk
$prog
BEGIN { ARGC=1; RS=FS=\"\n\" } { ARGC=1; RS=FS=\"\n\" }
"

: ${AWK=$(command -v gawk || echo awk)}
: ${EGREP=$(command -v ugrep || echo 'grep -E')}

if [ ! "$f" ]; then
	$EGREP -o "$JSON" - 2>/dev/null | $AWK -v __ARGV0="${0##*/}" "$@" "$prog"
else
	IFS=$(printf '\t')
	for file in $files; do
		unset IFS
		printf -- '---%s\n' "$file"
		$EGREP -o "$JSON" "$file" 2>/dev/null
	done | $AWK -v __ARGV0="${0##*/}" -v __ARGV="$files" "$@" "$prog"
fi
