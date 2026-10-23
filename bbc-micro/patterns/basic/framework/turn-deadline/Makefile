PYTHON ?= python3
.PHONY: all clean
all: build/demo.bas build/customise.bas build/wrong.bas
build/demo.bas: caller.bas routines.bas clock.bas monitor.bas turn.bas
	mkdir -p build
	cat caller.bas turn.bas routines.bas clock.bas monitor.bas > $@
build/customise.bas: customise.bas routines.bas clock.bas monitor.bas turn.bas
	mkdir -p build
	cat customise.bas turn.bas routines.bas clock.bas monitor.bas > $@
build/wrong.bas: caller.bas routines.bas mistakes/reset-baseline.bas monitor.bas turn.bas
	mkdir -p build
	cat caller.bas turn.bas routines.bas mistakes/reset-baseline.bas monitor.bas > $@
clean:
	rm -f build/demo.bas build/customise.bas build/wrong.bas
