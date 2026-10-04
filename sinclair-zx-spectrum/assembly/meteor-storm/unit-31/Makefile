# Build the checkpoint this unit's lesson runs (two-byte-score). Its source lives in
# checkpoints/two-byte-score/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/two-byte-score/meteor-storm.asm $(wildcard ../checkpoints/two-byte-score/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
