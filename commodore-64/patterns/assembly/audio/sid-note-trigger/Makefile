ASM ?= asm198x

all: demo.prg

demo.prg: demo.asm sid-note.inc
	$(ASM) --dialect acme --prg demo.asm -o $@

clean:
	rm -f demo.prg

.PHONY: all clean
