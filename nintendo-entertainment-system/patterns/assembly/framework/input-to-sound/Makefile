ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/demo.nes
build/demo.nes: demo.asm input.inc presses.inc tone.inc use.inc
	mkdir -p build
	$(ASM198X) --dialect ca65 demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
