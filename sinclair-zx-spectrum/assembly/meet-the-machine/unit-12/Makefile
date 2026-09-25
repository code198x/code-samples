# Build the program this unit's lesson assembles, under the name the lesson
# gives it. Any other source here is a variant the reader tries by hand; it
# stays unbuilt so the lesson's run strip runs the lesson's own program.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas

all: primer.tap

primer.tap: arithmetic.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f primer.tap

.PHONY: all clean
