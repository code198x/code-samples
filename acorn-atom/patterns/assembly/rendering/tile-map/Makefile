ASM198X ?= asm198x
PYTHON ?= python3
VARIANT ?= positive
.PHONY: all
all:
	$(PYTHON) ../../../../../scripts/verify-assembly-map-gaps.py --build-only --variant $(VARIANT) --only acorn-atom --assembler $(ASM198X)
