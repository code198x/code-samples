# Build the checkpoint this unit's lesson runs (timed-course). Its source lives in
# checkpoints/timed-course/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/timed-course/meteor-storm.asm $(wildcard ../checkpoints/timed-course/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
