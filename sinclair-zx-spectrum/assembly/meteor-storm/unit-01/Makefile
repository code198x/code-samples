# Build the checkpoint this unit's lesson runs (one-row-shift). Its source lives in
# checkpoints/one-row-shift/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/one-row-shift/meteor-storm.asm $(wildcard ../checkpoints/one-row-shift/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
