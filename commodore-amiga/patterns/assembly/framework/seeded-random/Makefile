ASM198X ?= asm198x
BUILD198X ?= build198x
.PHONY: all
all:
	mkdir -p build
	$(ASM198X) --dialect vasm --exe --sym=build/demo.sym demo.asm -o build/demo
	$(BUILD198X) adf build/demo -o build/demo.adf --name random --volume Random
	$(ASM198X) --dialect vasm --exe --sym=build/custom.sym custom.asm -o build/custom
	$(BUILD198X) adf build/custom -o build/custom.adf --name random --volume Random
	$(ASM198X) --dialect vasm --exe --sym=build/wrong.sym wrong.asm -o build/wrong
	$(BUILD198X) adf build/wrong -o build/wrong.adf --name random --volume Random
	$(ASM198X) --dialect vasm --exe --sym=build/repaired.sym repaired.asm -o build/repaired
	$(BUILD198X) adf build/repaired -o build/repaired.adf --name random --volume Random
