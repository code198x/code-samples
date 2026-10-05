# NES Makefile — built with Asm198x. Hand-maintained: generate-makefiles.sh
# leaves it alone because of the verify target.
ASM ?= asm198x
EMU ?= emu198x-nes
OUT ?= /tmp/square-wave

all: demo.nes

demo.nes: demo.asm square-wave.inc
	$(ASM) --dialect ca65 demo.asm -o $@

# Builds the demo and six variants and checks them in Emu198x; see README.md.
verify:
	python3 verification/verify.py --emulator $(EMU) --output $(OUT)

clean:
	rm -f demo.nes

.PHONY: all verify clean
