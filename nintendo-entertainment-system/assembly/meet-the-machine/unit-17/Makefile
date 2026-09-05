# NES Makefile — built with Asm198x
ASM ?= asm198x
SRC  = apu.asm
ROM  = apu.nes

.PHONY: all run clean

# Asm198x's ca65 dialect assembles and links to an iNES ROM in one step — its
# own bounded ld65 config, no external nes.cfg. Byte-identical to the retired
# ca65 + ld65 Docker build (verified 2026-07-09).
all: $(ROM)

$(ROM): $(SRC)
	$(ASM) --dialect ca65 $(SRC) -o $(ROM)

run: $(ROM)
	fceux $(ROM)

clean:
	rm -f $(ROM)
