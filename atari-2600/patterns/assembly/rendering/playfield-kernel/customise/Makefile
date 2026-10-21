ASM198X ?= asm198x
.PHONY: all clean
all: build/maze.a26 build/reflected.a26
build/%.a26: %.asm caller.inc ../playfield.inc ../kernel.inc
	mkdir -p build
	$(ASM198X) --dialect acme $< --sym=build/$*.sym -o $@
clean:
	rm -rf build
