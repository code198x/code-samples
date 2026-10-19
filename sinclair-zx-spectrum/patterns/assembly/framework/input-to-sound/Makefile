ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.tap build/demo.sna
build/demo.tap: demo.asm input.inc presses.inc use.asm ../../audio/sound-beep/sound-beep.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas demo.asm --sym=build/demo.sym -o $@
build/demo.sna: demo.asm input.inc presses.inc use.asm ../../audio/sound-beep/sound-beep.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --sna demo.asm -o $@
clean:
	rm -rf build
