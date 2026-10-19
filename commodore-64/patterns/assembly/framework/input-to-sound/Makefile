ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.prg
build/demo.prg: demo.asm ../../input/joystick-reading/joystick.inc ../../audio/sid-note-trigger/sid-note.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
