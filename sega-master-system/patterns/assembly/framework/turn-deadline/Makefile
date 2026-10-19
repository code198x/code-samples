ASM198X ?= asm198x
.PHONY: all clean
all: build/demo.sms
build/demo.sms: demo.asm frame.inc ../../../../../cross-platform/assembly/framework/turn-deadline/turn.inc ../../../../../scripts/build-sega-probe.py
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 demo.asm --sym=build/demo.sym -o $@
	python3 ../../../../../scripts/build-sega-probe.py $@
clean:
	rm -rf build
