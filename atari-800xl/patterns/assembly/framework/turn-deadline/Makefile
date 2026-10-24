ASM198X ?= asm198x
.PHONY: all
all: build/load.bas
build/demo.bin: demo.asm caller.inc clock.inc input.inc dispatch.inc ../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc
	mkdir -p build
	$(ASM198X) --dialect acme -I . --sym=build/demo.sym demo.asm -o $@
build/load.bas: build/demo.bin loader.py
	python3 loader.py
