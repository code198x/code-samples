ASM198X ?= asm198x
.PHONY: all
all: build/edges-demo.tap build/edges-custom.tap build/edges-wrong.tap
build/%.tap: %.asm edges.inc edges-caller.inc edges-display.inc ../../framework/input-to-sound/input.inc ../../framework/input-to-sound/presses.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=$(@:.tap=.sym) $< -o $@
