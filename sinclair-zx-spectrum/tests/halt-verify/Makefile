# ZX Spectrum halt-verify harness — built with Asm198x
ASM ?= asm198x

.PHONY: all clean

all: halt_test.sna

# Asm198x's pasmonext dialect writes the .sna directly. Byte-identical to the
# retired pasmonext Docker build, and to the .sna files checked in beside this
# (verified 2026-08-27).
%.sna: %.asm
	$(ASM) --dialect pasmonext --sna $< -o $@

clean:
	rm -f *.sna
