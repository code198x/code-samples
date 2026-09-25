# Build the checkpoint this unit's lesson runs (one-meteor). Its source lives in
# checkpoints/one-meteor/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/one-meteor/meteor-storm.asm $(wildcard ../checkpoints/one-meteor/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
