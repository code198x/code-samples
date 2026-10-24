HELPER = ../../../../../dragon-32/patterns/basic/framework/turn-deadline/routines.bas
COMMON = input.bas dispatch.bas presentation.bas monitor.bas
.PHONY: all
all: build/demo.bas build/customise.bas build/wrong.bas
build/demo.bas: caller.bas clock.bas $(HELPER) $(COMMON)
	mkdir -p build
	cat $^ > $@
build/customise.bas: customise.bas clock.bas $(HELPER) $(COMMON)
	mkdir -p build
	cat $^ > $@
build/wrong.bas: caller.bas mistakes/reset-baseline.bas $(HELPER) $(COMMON)
	mkdir -p build
	cat $^ > $@
