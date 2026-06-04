# Build every cumulative step. The last step is the complete unit program.
ASM = acme
ASMFLAGS = -f cbm
STEPS = $(wildcard steps/*.asm)
PRGS  = $(STEPS:.asm=.prg)
all: $(PRGS)
steps/%.prg: steps/%.asm
	$(ASM) $(ASMFLAGS) -o $@ $<
clean:
	rm -f steps/*.prg
.PHONY: all clean
