# Build the checkpoint this unit's lesson runs (object-records). Its source lives in
# checkpoints/object-records/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/object-records/meteor-storm.asm $(wildcard ../checkpoints/object-records/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
