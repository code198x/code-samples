# Build every cumulative step. The last step is the complete unit program.
ASM ?= asm198x
ASMFLAGS = --dialect pasmo --cpu z80 --tapbas
STEPS = $(wildcard steps/*.asm)
TAPS  = $(STEPS:.asm=.tap)

all: $(TAPS)

steps/%.tap: steps/%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f steps/*.tap

.PHONY: all clean
