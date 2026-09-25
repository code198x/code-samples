# Build the checkpoint this unit's lesson runs (object-pool). Its source lives in
# checkpoints/object-pool/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/object-pool/meteor-storm.asm $(wildcard ../checkpoints/object-pool/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
