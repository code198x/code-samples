ASM198X ?= asm198x
.PHONY: all clean
all:
	python3 ../../../../../cross-platform/patterns/rendering/word-wrap/build.py --system spectrum --assembler $(ASM198X)
	python3 ../../../../../cross-platform/patterns/rendering/word-wrap/build.py --system spectrum --assembler $(ASM198X) --variant customise
clean:
	rm -rf build
