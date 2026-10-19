ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/demo.nes
build/demo.nes: demo.asm frame.inc ../input-to-sound/input.inc
	mkdir -p build
	$(ASM198X) --dialect ca65 demo.asm --sym=build/demo.sym -o build/demo.nes
clean:
	rm -rf build
