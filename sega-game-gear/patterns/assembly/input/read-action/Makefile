ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.gg
build/demo.gg: demo.asm sample.inc picture.inc sound.inc ../../../../../scripts/build-sega-probe.py
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 demo.asm --sym=build/demo.sym -o $@
	python3 ../../../../../scripts/build-sega-probe.py $@
clean:
	rm -rf build
