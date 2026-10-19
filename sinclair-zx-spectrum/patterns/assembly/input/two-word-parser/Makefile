ASM198X ?= asm198x
PYTHON ?= python3
all: build/demo.tap
build/vocabulary.inc: vocabulary.json generate_vocabulary.py
	$(PYTHON) generate_vocabulary.py --output $@
build/demo.tap: demo.asm parser.inc build/vocabulary.inc ../../framework/game-loop/frame.inc ../../rendering/character-printing/characters.inc ../../rendering/numeric-display/numeric.inc
	$(ASM198X) --dialect pasmo --cpu z80 --tapbas --sym=build/demo.sym demo.asm -o $@
.PHONY: all
