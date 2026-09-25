# Build the checkpoint this unit's lesson runs (pixel-address). Its source lives in
# checkpoints/pixel-address/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/pixel-address/meteor-storm.asm $(wildcard ../checkpoints/pixel-address/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
