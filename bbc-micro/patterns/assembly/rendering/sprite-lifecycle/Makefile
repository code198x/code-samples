ASM198X ?= asm198x
.PHONY: all clean
all: build/loader.bas
build/loader.bas: demo.asm background.inc loader.py ../masked-sprites/masked.inc
	mkdir -p build
	$(ASM198X) --dialect acme --sym=build/demo.sym demo.asm -o build/demo.bin
	python3 loader.py
clean:
	rm -rf build
