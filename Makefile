CFLAGS=-std=c23 -g -fno-common -Wall -Wno-switch

SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)

TEST_SRCS=$(wildcard test/*.c)
TESTS=$(TEST_SRCS:.c=.exe)

all: test test-stage2 test-stage3

# Stage 1 - build chibicc with the host cc

chibicc: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJS): chibicc.h Makefile

test/%.exe: chibicc test/%.c
	./chibicc -Iinclude -Itest -c -o test/$*.o test/$*.c
	$(CC) -o $@ test/$*.o -xc test/common

test: $(TESTS)
	for i in $^; do echo $$i; ./$$i || exit 1; echo; done
	test/driver.sh ./chibicc

# Stage 2 - build chibicc with the host-built chibicc

stage2/chibicc: $(OBJS:%=stage2/%)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

stage2/%.o: chibicc %.c
	mkdir -p stage2/test
	./chibicc -c -o $(@D)/$*.o $*.c

stage2/test/%.exe: stage2/chibicc test/%.c
	mkdir -p stage2/test
	./stage2/chibicc -Iinclude -Itest -c -o stage2/test/$*.o test/$*.c
	$(CC) -o $@ stage2/test/$*.o -xc test/common

test-stage2: $(TESTS:test/%=stage2/test/%)
	for i in $^; do echo $$i; ./$$i || exit 1; echo; done
	test/driver.sh ./stage2/chibicc

# Stage 3 - build chibicc with the chibicc-built chibicc

stage3/chibicc: $(OBJS:%=stage3/%)
	./stage2/chibicc $(CFLAGS) -o $@ $^ $(LDFLAGS)

stage3/%.o: stage2/chibicc %.c
	mkdir -p stage3/test
	./stage2/chibicc -Iinclude -c -o $(@D)/$*.o $*.c

stage3/test/%.exe: stage3/chibicc test/%.c
	mkdir -p stage3/test
	./stage3/chibicc -Iinclude -Itest -c -o stage3/test/$*.o test/$*.c
	$(CC) -o $@ stage3/test/$*.o -xc test/common

test-stage3: $(TESTS:test/%=stage3/test/%)
	for i in $^; do echo $$i; ./$$i || exit 1; echo; done
	test/driver.sh ./stage3/chibicc

# Misc.

clean:
	rm -rf chibicc tmp* $(TESTS) test/*.s test/*.exe stage2 stage3
	find * -type f '(' -name '*~' -o -name '*.o' ')' -exec rm {} ';'

.PHONY: all clean test test-stage2 test-stage3
