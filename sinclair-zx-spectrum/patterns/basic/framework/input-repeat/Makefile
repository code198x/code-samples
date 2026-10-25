PYTHON ?= python3
BUILD198X ?= build198x
.PHONY: all
all:
	$(PYTHON) build.py
	$(BUILD198X) basic build/demo.bas --machine sinclair-zx-spectrum -o build/demo.tap
	$(BUILD198X) basic build/custom.bas --machine sinclair-zx-spectrum -o build/custom.tap
	$(BUILD198X) basic build/wrong.bas --machine sinclair-zx-spectrum -o build/wrong.tap
	$(BUILD198X) basic build/repaired.bas --machine sinclair-zx-spectrum -o build/repaired.tap
