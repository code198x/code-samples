ASM198X ?= asm198x
.PHONY: all clean
all: build/loader.bas
build/loader.bas: demo.asm settings.inc dispatch.inc loader.py ../../../../../cross-platform/patterns/framework/command-turns/z80.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo demo.asm --sym=build/demo.sym -o build/demo.bin
	python3 loader.py
clean:
	rm -rf build
