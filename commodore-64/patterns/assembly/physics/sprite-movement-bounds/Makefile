ASM198X ?= asm198x
EMU198X_C64 ?= emu198x-c64
VICE ?= x64sc
SPRITES = ../../rendering/hardware-sprites

.PHONY: all verify clean
all: build/demo.prg

build/demo.prg: demo.asm movement.inc $(SPRITES)/sprite.inc $(SPRITES)/shape.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg demo.asm -o $@

verify:
	python3 verification/verify.py --assembler "$(ASM198X)" --emulator "$(EMU198X_C64)" --vice "$(VICE)"

clean:
	rm -rf build
