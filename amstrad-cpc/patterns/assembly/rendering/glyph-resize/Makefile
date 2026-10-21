ASM198X ?= asm198x
.PHONY: all clean
all:
	python3 ../../../../../cross-platform/patterns/rendering/glyph-resize/build.py --system amstrad-cpc --assembler $(ASM198X)
	python3 ../../../../../cross-platform/patterns/rendering/glyph-resize/build.py --system amstrad-cpc --assembler $(ASM198X) --variant customise
clean:
	rm -rf build
