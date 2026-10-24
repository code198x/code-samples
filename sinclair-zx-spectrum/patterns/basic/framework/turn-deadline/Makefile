BUILD198X ?= build198x
PARTS = dispatch.bas input.bas routines.bas clock.bas presentation.bas monitor.bas
.PHONY: all
all: build/demo.tap build/customise.tap build/wrong.tap
build/demo.bas: caller.bas $(PARTS)
	mkdir -p build
	sort -n caller.bas $(PARTS) > $@
build/customise.bas: customise.bas $(PARTS)
	mkdir -p build
	sort -n customise.bas $(PARTS) > $@
build/wrong.bas: caller.bas dispatch.bas input.bas routines.bas mistakes/reset-baseline.bas presentation.bas monitor.bas
	mkdir -p build
	sort -n $^ > $@
build/%.tap: build/%.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@
