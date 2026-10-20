ASM198X ?= asm198x
BUILD198X ?= build198x
ADF_SUBCOMMAND ?= $(if $(filter build198x-adf,$(notdir $(BUILD198X))),,adf)
PYTHON ?= python3
PREP=../../../../../cross-platform/patterns/rendering/pre-shifted-sprites
.PHONY: all regenerate check-assets clean
all: build/demo.adf
regenerate:
	$(PYTHON) $(PREP)/prepare.py $(PREP)/sprite.json --system amiga --output phases.inc
check-assets:
	$(PYTHON) $(PREP)/prepare.py $(PREP)/sprite.json --system amiga --output phases.inc --check
build/demo: demo.asm phase.inc phases.inc ../clipped-sprites/clip.inc ../clipped-sprites/draw.inc ../../framework/game-loop/frame.inc
	mkdir -p build
	$(ASM198X) --dialect vasm --exe --sym=build/demo.sym demo.asm -o $@
build/demo.adf: build/demo
	$(BUILD198X) $(ADF_SUBCOMMAND) build/demo -o $@ --name demo
clean:
	rm -rf build
