CFLAGS = -Wall
BINARIES = execveat
DEPS = execveat.symlink execveat.denatured script subdir
all: $(BINARIES) $(DEPS)

subdir:
	mkdir -p $@
script:
	echo '#!/bin/sh' > $@
	echo 'exit $$*' >> $@
	chmod +x $@
execveat.symlink: execveat
	ln -s -f $< $@
execveat.denatured: execveat
	cp $< $@
	chmod -x $@
%: %.c
	$(CC) $(CFLAGS) -o $@ $^

TEST_PROGS := execveat
TEST_FILES := $(DEPS)

include ../lib.mk

clean:
	rm -rf $(BINARIES) $(DEPS) subdir.moved execveat.moved xxxxx*
