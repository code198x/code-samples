# Build the checkpoint this unit's lesson runs (clocked-steering). Its source lives in
# checkpoints/clocked-steering/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/clocked-steering/meteor-storm.asm $(wildcard ../checkpoints/clocked-steering/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
