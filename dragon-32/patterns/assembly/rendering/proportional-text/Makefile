ASM198X ?= asm198x
.PHONY: all clean
all:
	python3 ../../../../../cross-platform/patterns/rendering/proportional-text/build.py --system dragon --assembler $(ASM198X)
	python3 ../../../../../cross-platform/patterns/rendering/proportional-text/build.py --system dragon --assembler $(ASM198X) --variant customise
clean:
	rm -rf build
