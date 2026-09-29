# Build the checkpoint this unit's lesson runs (elapsed-time). Its source lives in
# checkpoints/elapsed-time/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/elapsed-time/meteor-storm.asm $(wildcard ../checkpoints/elapsed-time/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
