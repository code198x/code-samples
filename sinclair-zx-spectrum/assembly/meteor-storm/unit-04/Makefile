# Build the checkpoint this unit's lesson runs (draw-ship). Its source lives in
# checkpoints/draw-ship/; this folder exists so the site can stage the tape where the lesson looks for it.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: meteor-storm.tap

meteor-storm.tap: ../checkpoints/draw-ship/meteor-storm.asm $(wildcard ../checkpoints/draw-ship/*.inc)
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f meteor-storm.tap

.PHONY: all clean
