ASM198X ?= asm198x
VARIANT ?= positive

all:
	python3 ../../../../../scripts/verify-remaining-assembly-maps.py --only atari-800xl --build-only --assembler "$(ASM198X)" --variant "$(VARIANT)"

.PHONY: all
