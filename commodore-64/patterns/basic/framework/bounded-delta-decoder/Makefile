PYTHON ?= python3
BUILD198X ?= build198x
.PHONY: all
all:
	$(PYTHON) build.py
	$(BUILD198X) basic build/demo.bas --machine commodore-c64 -o build/demo.prg
	$(BUILD198X) basic build/custom.bas --machine commodore-c64 -o build/custom.prg
	$(BUILD198X) basic build/wrong.bas --machine commodore-c64 -o build/wrong.prg
	$(BUILD198X) basic build/repaired.bas --machine commodore-c64 -o build/repaired.prg
