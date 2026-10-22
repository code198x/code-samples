BUILD198X ?= build198x

.PHONY: all clean
all: build/demo.tap

build/demo.tap: demo.bas
	mkdir -p build
	cp demo.bas build/demo.bas
	$(BUILD198X) basic lint build/demo.bas --machine sinclair-zx-spectrum --fix
	$(BUILD198X) basic build/demo.bas --machine sinclair-zx-spectrum -o $@

clean:
	rm -rf build
