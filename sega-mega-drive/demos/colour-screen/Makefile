ASM198X ?= asm198x

.PHONY: all clean
all: demo.bin

demo.bin: demo.asm
	$(ASM198X) --dialect vasm $< -o $@

clean:
	rm -f demo.bin
