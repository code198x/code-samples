ASM198X ?= asm198x
all:
	mkdir -p build
	$(ASM198X) --dialect ca65 --sym demo.asm -o build/demo.nes
	$(ASM198X) --dialect ca65 --sym custom.asm -o build/custom.nes
	$(ASM198X) --dialect ca65 --sym wrong.asm -o build/wrong.nes
	$(ASM198X) --dialect ca65 --sym repaired.asm -o build/repaired.nes
clean:
	rm -rf build
