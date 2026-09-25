# Build the program this unit's lesson assembles. Its source lives in opening/.
# This folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: eight-rows.tap

eight-rows.tap: ../opening/eight-rows.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f eight-rows.tap

.PHONY: all clean
