# Build the program this unit's lesson assembles. Its source lives in opening/.
# This folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: one-byte.tap

one-byte.tap: ../opening/one-byte.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f one-byte.tap

.PHONY: all clean
