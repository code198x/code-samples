ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.nes
build/demo.nes: demo.asm scroll.inc ../multi-sprite-oam/oam.inc
	mkdir -p build
	$(ASM198X) --dialect ca65 demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
