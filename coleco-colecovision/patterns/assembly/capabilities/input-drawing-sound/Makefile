ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.cv
build/demo.cv: demo.asm picture.inc sound.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
