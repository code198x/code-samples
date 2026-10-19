ASM198X ?= asm198x
.PHONY: all clean
all: build/loader.bas
build/loader.bas: demo.asm clip.inc draw.inc shapes.inc loader.py
	mkdir -p build
	$(ASM198X) --dialect acme --sym=build/demo.sym demo.asm -o build/demo.bin
	python3 loader.py
clean:
	rm -rf build
