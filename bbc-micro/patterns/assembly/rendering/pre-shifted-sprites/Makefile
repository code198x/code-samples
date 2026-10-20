ASM198X ?= asm198x
PYTHON ?= python3
PREP=../../../../../cross-platform/patterns/rendering/pre-shifted-sprites
.PHONY: all clean regenerate check-assets
all: build/loader.bas
regenerate:
	$(PYTHON) $(PREP)/prepare.py $(PREP)/sprite.json --system bbc --output phases.inc
check-assets:
	$(PYTHON) $(PREP)/prepare.py $(PREP)/sprite.json --system bbc --output phases.inc --check
build/loader.bas: loader.py demo.asm phase.inc draw.inc phases.inc ../clipped-sprites/clip.inc
	mkdir -p build
	$(ASM198X) --dialect acme --sym=build/demo.sym demo.asm -o build/demo.bin
	$(PYTHON) loader.py
clean:
	rm -rf build
