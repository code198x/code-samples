# Build the checkpoint this unit's lesson runs (star-pickups). Its source lives in
# checkpoints/star-pickups/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/star-pickups/meteor-storm.asm $(wildcard ../checkpoints/star-pickups/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
