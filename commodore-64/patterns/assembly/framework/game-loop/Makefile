ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/demo.prg
build/demo.prg: demo.asm frame.inc ../../input/joystick-reading/joystick.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg demo.asm --sym=build/demo.sym -o build/demo.prg
clean:
	rm -rf build
