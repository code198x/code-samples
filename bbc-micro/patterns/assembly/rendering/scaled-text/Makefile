ASM198X ?= asm198x
.PHONY: all clean
all:
	python3 ../../../../../cross-platform/patterns/rendering/scaled-text/build.py --system acorn-bbc-micro --assembler $(ASM198X)
	python3 ../../../../../cross-platform/patterns/rendering/scaled-text/build.py --system acorn-bbc-micro --assembler $(ASM198X) --variant customise
clean:
	rm -rf build
