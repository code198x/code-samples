ASM198X ?= asm198x
.PHONY: all
all: build/demo.tap
build/demo.tap: demo.asm caller.inc clock.inc input.inc dispatch.inc ../../../../../cross-platform/patterns/framework/elapsed-deadline/z80.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/demo.sym demo.asm -o $@
