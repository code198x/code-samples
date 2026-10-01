ASM ?= asm198x

all: demo.tap

demo.tap: demo.asm sound-beep.inc effects.inc
	$(ASM) --dialect pasmo --cpu z80 --tapbas demo.asm -o $@

clean:
	rm -f demo.tap

.PHONY: all clean
