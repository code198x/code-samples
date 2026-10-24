ASM198X ?= asm198x
.PHONY: all
all:
	mkdir -p build
	$(ASM198X) --dialect acme --prg --sym=build/demo.sym demo.asm -o build/demo.prg
	$(ASM198X) --dialect acme --prg --sym=build/custom.sym custom.asm -o build/custom.prg
	$(ASM198X) --dialect acme --prg --sym=build/wrong.sym wrong.asm -o build/wrong.prg
	$(ASM198X) --dialect acme --prg --sym=build/repaired.sym repaired.asm -o build/repaired.prg
