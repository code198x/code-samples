ASM198X ?= asm198x
CHECKPOINTS := 01-junction 02-switch 03-delivery
CARTS := $(addprefix build/,$(addsuffix .gb,$(CHECKPOINTS)))

.PHONY: all clean
all: $(CARTS)

build/02-switch.gb build/03-delivery.gb: joypad.inc

build/%.gb: %.asm yard.inc
	mkdir -p build
	$(ASM198X) --dialect rgbasm --gb-rom --tiny $< --sym=$(@:.gb=.sym) -o $@

clean:
	rm -rf build
