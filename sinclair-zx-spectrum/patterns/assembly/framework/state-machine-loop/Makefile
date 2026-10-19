ASM198X ?= asm198x
all: build/demo.tap
build/demo.tap: demo.asm ../game-loop/frame.inc ../input-to-sound/input.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/demo.sym demo.asm -o $@
.PHONY: all
