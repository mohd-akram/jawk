JSON_AWK_URL=https://raw.githubusercontent.com/step-/JSON.awk/master/JSON.awk

all: jawk

jawk: src/jawk.sh src/JSON.awk
	sed "$$(printf '%s\n' \
		'/^parser=/{' \
		'r src/JSON.awk' \
		'a\' \
		\' \
		'c\' \
		"parser='" \
		'}')" src/jawk.sh > $@ && chmod +x $@ || rm $@

src/JSON.awk.orig:
	curl $(JSON_AWK_URL) > $@

src/JSON.awk: src/JSON.awk.orig src/patch-json-awk.diff
	patch -o $@ src/JSON.awk.orig < src/patch-json-awk.diff || rm $@

src/patch-json-awk.diff: src/JSON.awk.orig src/JSON.awk
	diff -u src/JSON.awk.orig src/JSON.awk > $@ || [ $$? = 1 ]

test: jawk .force
	test/run.sh

.force:

prefix = /usr/local
bindir = $(prefix)/bin

install: jawk
	install -d $(DESTDIR)$(bindir)
	install jawk $(DESTDIR)$(bindir)
