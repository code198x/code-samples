ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.a26
build/demo.a26: demo.asm picture.inc sound.inc
	mkdir -p build
	$(ASM198X) --dialect acme demo.asm --sym=build/demo.sym -o $@
clean:
	rm -rf build
