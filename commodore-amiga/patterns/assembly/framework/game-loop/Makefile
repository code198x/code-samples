ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/demo.adf
build/demo.adf: demo.asm frame.inc ../input-to-sound/input.inc
	mkdir -p build
	$(ASM198X) --dialect vasm --exe demo.asm --sym=build/demo.sym -o build/demo
	$(BUILD198X) adf build/demo -o build/demo.adf --name demo --volume GameLoop
clean:
	rm -rf build
