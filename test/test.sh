isfirst=true
i=0
s=0

printline() {
	i=$((i+1))
	[ "$1" -eq 0 ] && printf "ok %d - %s\n" $i "$cur" && return
	printf "not ok %d - %s\n" $i "$cur"
	s=1
}

test() {
	ls=$?
	$isfirst && cur="$1" && isfirst=false && return
	printline $ls
	cur=$1
}

printplan() {
	printf "1..%s\n" "$i"
}

finish() {
	ls=$?
	[ -z "$cur" ] && exit
	printline $ls
	printplan
	exit $s
}

trap finish EXIT
