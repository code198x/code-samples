# Build the checkpoint this unit's lesson runs (interrupt-clock). Its source lives in
# checkpoints/interrupt-clock/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/interrupt-clock/meteor-storm.asm $(wildcard ../checkpoints/interrupt-clock/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
