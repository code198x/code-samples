ASM198X ?= asm198x
PYTHON ?= python3
.PHONY: all
all: build/loader.bas
build/demo.bin: demo.asm settings.inc clock.inc input.inc dispatch.inc ../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc
	mkdir -p build
	$(ASM198X) --dialect acme demo.asm -o $@
build/loader.bas: build/demo.bin loader.py
	$(PYTHON) loader.py
