ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.rom
build/demo.rom: demo.asm
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
