ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.prg
build/demo.prg: demo.asm collision.inc rules.inc state.inc draw.inc sound.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg demo.asm --sym=build/demo.sym -o build/demo.prg
clean:
	rm -rf build
