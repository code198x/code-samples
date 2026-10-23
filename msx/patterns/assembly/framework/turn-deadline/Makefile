ASM ?= asm198x
.PHONY: all
all: build/load.bas
build/demo.bin: demo.asm caller.inc clock.inc input.inc dispatch.inc ../../../../../cross-platform/patterns/framework/elapsed-deadline/z80.inc
	mkdir -p build
	$(ASM) --dialect pasmo -I . --sym demo.asm -o $@
build/load.bas: build/demo.bin loader.py
	python3 loader.py
