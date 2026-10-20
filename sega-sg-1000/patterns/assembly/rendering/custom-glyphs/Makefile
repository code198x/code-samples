# Original fixture; asm198x must be on PATH or supplied with ASM.
ASM ?= asm198x
.PHONY: all clean
all:
	python3 ../../../../../cross-platform/patterns/rendering/tms-glyphs/build.py --system sega-sg-1000 --assembler $(ASM)
clean:
	rm -rf build
