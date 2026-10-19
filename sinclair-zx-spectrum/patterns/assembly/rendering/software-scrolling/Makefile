ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.tap
build/demo.tap: demo.asm scroll.inc ../bitmap-addressing/bitmap-addressing.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/demo.sym demo.asm -o $@
clean:
	rm -rf build
