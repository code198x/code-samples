# Build the checkpoint this unit's lesson runs (first-dodge). Its source lives in
# checkpoints/first-dodge/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/first-dodge/meteor-storm.asm $(wildcard ../checkpoints/first-dodge/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
