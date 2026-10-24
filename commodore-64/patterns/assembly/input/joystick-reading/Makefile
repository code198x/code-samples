ASM198X ?= asm198x
EMU198X_C64 ?= emu198x-c64
VICE ?= x64sc

.PHONY: all verify clean
all: build/demo.prg

build/demo.prg: demo.asm joystick.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg demo.asm -o $@

verify:
	python3 verification/verify.py --assembler "$(ASM198X)" --emulator "$(EMU198X_C64)" --vice "$(VICE)"

clean:
	rm -rf build

.PHONY: edges
edges: build/edges-demo.prg build/edges-custom.prg build/edges-wrong.prg
build/edges-demo.prg: edges-demo.asm edges-caller.inc edges.inc joystick.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg --sym=build/edges-demo.sym edges-demo.asm -o $@
build/edges-custom.prg: edges-custom.asm edges-caller.inc edges.inc joystick.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg --sym=build/edges-custom.sym edges-custom.asm -o $@
build/edges-wrong.prg: edges-wrong.asm edges-caller.inc edges-wrong.inc edges.inc joystick.inc
	mkdir -p build
	$(ASM198X) --dialect acme --prg --sym=build/edges-wrong.sym edges-wrong.asm -o $@
