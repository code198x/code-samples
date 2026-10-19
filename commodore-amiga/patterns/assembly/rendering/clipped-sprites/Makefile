ASM198X ?= asm198x
BUILD198X ?= build198x-adf
.PHONY: all clean
all: build/demo.adf
build/demo: demo.asm clip.inc draw.inc shapes.inc ../../framework/game-loop/frame.inc
	mkdir -p build
	$(ASM198X) --dialect vasm --exe --sym=build/demo.sym demo.asm -o $@
build/demo.adf: build/demo
	$(BUILD198X) build/demo -o $@ --name demo
clean:
	rm -rf build
