ASM ?= asm198x
ASM198X ?= $(ASM)
.PHONY: all clean
all:
	python3 ../../../../../cross-platform/patterns/rendering/native-glyphs/build.py --system c64 --assembler $(ASM)
clean:
	rm -rf build

rom-font:
	mkdir -p build/rom
	"$(ASM198X)" --dialect acme --prg --sym=build/rom/rom-demo.sym rom-demo.asm -o build/rom/rom-demo.prg
	"$(ASM198X)" --dialect acme --prg --sym=build/rom/rom-custom.sym rom-custom.asm -o build/rom/rom-custom.prg
	"$(ASM198X)" --dialect acme --prg --sym=build/rom/rom-wrong.sym rom-wrong.asm -o build/rom/rom-wrong.prg
	"$(ASM198X)" --dialect acme --prg --sym=build/rom/rom-repaired.sym rom-repaired.asm -o build/rom/rom-repaired.prg
