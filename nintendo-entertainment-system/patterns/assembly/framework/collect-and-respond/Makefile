ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.nes
build/demo.nes: demo.asm collision.inc rules.inc draw.inc sound.inc ../game-loop/frame.inc ../input-to-sound/input.inc ../../audio/square-wave/square-wave.inc
	mkdir -p build
	$(ASM198X) --dialect ca65 demo.asm --sym=build/demo.sym -o build/demo.nes
clean:
	rm -rf build
