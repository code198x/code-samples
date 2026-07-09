# Commodore 64 Makefile — built with Asm198x
ASM ?= asm198x
SRC  = symphony.asm
OUT  = symphony.prg

.PHONY: all run clean

# Asm198x's acme dialect emits a .prg (2-byte load address prepended).
# Byte-identical to the retired ACME Docker build (verified 2026-07-09).
all: $(OUT)

$(OUT): $(SRC)
	$(ASM) --dialect acme --prg $(SRC) -o $(OUT)

run: $(OUT)
	x64sc $(OUT)

clean:
	rm -f $(OUT)
