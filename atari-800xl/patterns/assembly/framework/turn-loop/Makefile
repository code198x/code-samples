ASM198X ?= asm198x
.PHONY: all clean
all: build/loader.bas
build/loader.bas: demo.asm settings.inc frame.inc loader.py ../../../../../cross-platform/patterns/framework/atari-turn-loops/turn.inc ../../../../../cross-platform/patterns/framework/atari-turn-loops/edge-filter.inc
	mkdir -p build
	$(ASM198X) --dialect acme demo.asm --sym=build/demo.sym -o build/demo.bin
	python3 loader.py
clean:
	rm -rf build
