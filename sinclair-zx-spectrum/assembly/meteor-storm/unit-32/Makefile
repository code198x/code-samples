# Build the checkpoint this unit's lesson runs (storm-bonus). Its source lives in
# checkpoints/storm-bonus/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/storm-bonus/meteor-storm.asm $(wildcard ../checkpoints/storm-bonus/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
