# Build the checkpoint this unit's lesson runs (sound-frames). Its source lives in
# checkpoints/sound-frames/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/sound-frames/meteor-storm.asm $(wildcard ../checkpoints/sound-frames/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
