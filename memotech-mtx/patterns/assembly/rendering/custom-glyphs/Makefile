# Original fixture; asm198x must be on PATH or supplied with ASM.
ASM ?= asm198x
.PHONY: all clean
all:
	python3 ../../../../../cross-platform/patterns/rendering/tms-glyphs/build.py --system memotech-mtx --assembler $(ASM)
clean:
	rm -rf build
