ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.gb
build/demo.gb: demo.asm
	mkdir -p build
	$(ASM198X) --dialect rgbasm --gb-rom demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
