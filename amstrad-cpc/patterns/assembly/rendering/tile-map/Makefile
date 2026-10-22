ASM198X ?= asm198x
VARIANT ?= positive

all:
	python3 ../../../../../scripts/verify-remaining-assembly-maps.py --only amstrad-cpc --build-only --assembler "$(ASM198X)" --variant "$(VARIANT)"

.PHONY: all
