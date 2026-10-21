ASM198X ?= asm198x
.PHONY: all clean
all: build/ships.bin
build/ships.bin: ships.asm ship.inc ../objects.inc
	mkdir -p build
	$(ASM198X) --dialect acme ships.asm --sym=build/ships.sym -o $@
clean:
	rm -rf build
