ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all clean
all: build/loader.bas
build/loader.bas: demo.asm frame.inc loader.py
	mkdir -p build
	$(ASM198X) --dialect acme demo.asm --sym=build/demo.sym -o build/demo.bin
	python3 loader.py
clean:
	rm -rf build
