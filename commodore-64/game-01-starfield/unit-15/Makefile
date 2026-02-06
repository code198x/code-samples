ASM = acme
ASMFLAGS = -f cbm

starfield.prg: starfield.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f starfield.prg

.PHONY: clean
