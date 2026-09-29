# Build the checkpoint this unit's lesson runs (sound-table). Its source lives in
# checkpoints/sound-table/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/sound-table/meteor-storm.asm $(wildcard ../checkpoints/sound-table/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
