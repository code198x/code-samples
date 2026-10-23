ASM ?= asm198x
.PHONY: all
all: build/load.bas
build/demo.bin: demo.asm caller.inc clock.inc deadline.inc dispatch.inc
	mkdir -p build
	$(ASM) --dialect lwasm -I . --sym demo.asm -o $@
build/load.bas: build/demo.bin loader.py
	python3 loader.py
