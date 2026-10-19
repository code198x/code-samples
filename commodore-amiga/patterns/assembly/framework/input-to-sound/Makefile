ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/demo.adf
build/demo.adf: demo.asm input.inc presses.inc use.asm ../../audio/playing-a-sample/paula-sample.inc
	mkdir -p build
	$(ASM198X) --dialect vasm --exe demo.asm --sym=build/demo.sym -o build/demo
	$(BUILD198X) adf build/demo -o $@ --volume Input --name demo
clean:
	rm -rf build
