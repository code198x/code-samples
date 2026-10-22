ASM198X ?= asm198x
PYTHON ?= python3
.PHONY: all clean
all: build/demo.bas
build/demo.bin: demo.asm sample.inc picture.inc sound.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 demo.asm --sym=build/demo.sym -o $@
build/demo.bas: build/demo.bin ../../../../../scripts/build-stock-probe.py
	$(PYTHON) ../../../../../scripts/build-stock-probe.py --system memotech-mtx --binary $< --output $@
clean:
	rm -rf build
