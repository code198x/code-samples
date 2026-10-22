ASM198X ?= asm198x
SHARED = ../../../../../cross-platform/patterns/framework/atari-turn-loops
.PHONY: all clean
all: build/demo.a26
build/demo.a26: demo.asm settings.inc $(SHARED)/turn.inc $(SHARED)/edge-filter.inc overscan-count.inc
	mkdir -p build
	$(ASM198X) --dialect acme demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
