# Build every cumulative step. The last step is the complete unit program.
ASM ?= asm198x
ASMFLAGS = --dialect acme --prg
STEPS = $(wildcard steps/*.asm)
PRGS  = $(STEPS:.asm=.prg)

all: $(PRGS)

steps/%.prg: steps/%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f steps/*.prg

.PHONY: all clean
