# Build the program this unit's lesson assembles. Its source lives in opening/.
# This folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: move-character.tap

move-character.tap: ../opening/move-character.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f move-character.tap

.PHONY: all clean
