# Build the checkpoint this unit's lesson runs (furthest-storm). Its source lives in
# checkpoints/furthest-storm/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/furthest-storm/meteor-storm.asm $(wildcard ../checkpoints/furthest-storm/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
