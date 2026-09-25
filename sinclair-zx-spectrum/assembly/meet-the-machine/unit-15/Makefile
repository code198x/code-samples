# Build the program this unit's lesson assembles, under the name the lesson
# gives it. Any other source here is a variant the reader tries by hand; it
# stays unbuilt so the lesson's run strip runs the lesson's own program.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: beeper.tap

beeper.tap: beeper.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f beeper.tap

.PHONY: all clean
