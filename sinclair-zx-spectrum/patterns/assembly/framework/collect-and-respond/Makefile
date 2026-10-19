ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.sna
build/demo.sna: demo.asm collision.inc rules.inc draw.inc sound.inc ../game-loop/frame.inc ../input-to-sound/input.inc ../../audio/sound-beep/sound-beep.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --sna demo.asm --sym=build/demo.sym -o build/demo.sna
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas demo.asm -o build/demo.tap
clean:
	rm -rf build
