ASM198X ?= asm198x
.PHONY: all
all:
	mkdir -p build
	$(ASM198X) --dialect ca65 --sym=build/demo.sym demo.asm -o build/demo.nes
	$(ASM198X) --dialect ca65 --sym=build/custom.sym custom.asm -o build/custom.nes
	$(ASM198X) --dialect ca65 --sym=build/wrong.sym wrong.asm -o build/wrong.nes
	$(ASM198X) --dialect ca65 --sym=build/repaired.sym repaired.asm -o build/repaired.nes
