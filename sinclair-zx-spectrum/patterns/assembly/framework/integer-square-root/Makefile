ASM198X ?= asm198x
.PHONY: all
all:
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/demo.sym demo.asm -o build/demo.tap
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/custom.sym custom.asm -o build/custom.tap
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/wrong.sym wrong.asm -o build/wrong.tap
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/repaired.sym repaired.asm -o build/repaired.tap
