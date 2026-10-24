ASM198X ?= asm198x
.PHONY: all
all: build/edges-demo.nes build/edges-custom.nes build/edges-wrong.nes
build/%.nes: %.asm edges-caller.inc edges.inc edges-font.inc ../../framework/input-to-sound/input.inc ../../framework/input-to-sound/presses.inc
	mkdir -p build
	$(ASM198X) --dialect ca65 --sym=$(@:.nes=.sym) $< -o $@
