ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.sg
build/demo.sg: demo.asm picture.inc sound.inc ../../../../../scripts/build-sega-probe.py
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 demo.asm --sym=build/demo.sym -o $@
	python3 ../../../../../scripts/build-sega-probe.py $@
clean:
	rm -rf build
