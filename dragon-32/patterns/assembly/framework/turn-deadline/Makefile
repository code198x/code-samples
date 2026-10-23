ASM ?= asm198x
.PHONY: all
all: build/demo.bin
build/demo.bin: demo.asm caller.inc clock.inc deadline.inc dispatch.inc
	mkdir -p build
	$(ASM) --dialect lwasm -I . --sym demo.asm -o $@
