ASM198X ?= asm198x
PYTHON ?= python3
PREP=../../../../../cross-platform/patterns/rendering/pre-shifted-sprites
.PHONY: all clean regenerate check-assets
all: build/demo.tap
regenerate:
	$(PYTHON) $(PREP)/prepare.py $(PREP)/sprite.json --system spectrum --output phases.inc
check-assets:
	$(PYTHON) $(PREP)/prepare.py $(PREP)/sprite.json --system spectrum --output phases.inc --check
build/demo.tap: demo.asm phase.inc draw.inc phases.inc ../clipped-sprites/clip.inc ../bitmap-addressing/bitmap-addressing.inc
	mkdir -p build
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/demo.sym demo.asm -o $@
clean:
	rm -rf build
