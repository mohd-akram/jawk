all: jawk

jawk: src/jawk.sh src/jawk.awk
	sed "$$(printf '%s\n' \
		'/^jawk=/{' 'r src/jawk.awk' 'a\' \' 'c\' "jawk='" '}' \
		)" src/jawk.sh | grep -v '^[[:blank:]]*#[^!]' > $@ && \
		chmod +x $@ || rm $@

test: jawk .force
	test/run.sh

.force:

prefix = /usr/local
bindir = $(prefix)/bin

install: jawk
	install -d $(DESTDIR)$(bindir)
	install jawk $(DESTDIR)$(bindir)
