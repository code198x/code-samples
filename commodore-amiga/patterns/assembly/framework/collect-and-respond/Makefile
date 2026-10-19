ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/demo.adf
build/demo.adf: demo.asm collision.inc rules.inc draw.inc sound.inc ../game-loop/frame.inc ../input-to-sound/input.inc ../../audio/playing-a-sample/paula-sample.inc
	mkdir -p build
	$(ASM198X) --dialect vasm --exe demo.asm --sym=build/demo.sym -o build/demo
	$(BUILD198X) adf build/demo -o build/demo.adf --name demo --volume Collect
clean:
	rm -rf build
