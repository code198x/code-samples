ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/demo.sna
build/demo.sna: demo.asm frame.inc ../input-to-sound/input.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --sna demo.asm --sym=build/demo.sym -o build/demo.sna
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas demo.asm -o build/demo.tap
clean:
	rm -rf build
