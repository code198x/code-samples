SHARED = ../../../../../commodore-64/patterns/basic/framework/turn-deadline
.PHONY: all
all: build/demo.bas build/customise.bas build/wrong.bas
build/observer.bas: $(SHARED)/monitor.bas
	mkdir -p build
	awk '$$1 >= 9000' $< > $@
build/demo.bas: caller.bas routines.bas clock.bas presentation.bas $(SHARED)/../command-loop/routines.bas build/observer.bas
	cat caller.bas $(SHARED)/../command-loop/routines.bas routines.bas clock.bas presentation.bas build/observer.bas > $@
build/customise.bas: customise.bas routines.bas clock.bas presentation.bas $(SHARED)/../command-loop/routines.bas build/observer.bas
	cat customise.bas $(SHARED)/../command-loop/routines.bas routines.bas clock.bas presentation.bas build/observer.bas > $@
build/wrong.bas: caller.bas routines.bas mistakes/reset-baseline.bas presentation.bas $(SHARED)/../command-loop/routines.bas build/observer.bas
	cat caller.bas $(SHARED)/../command-loop/routines.bas routines.bas mistakes/reset-baseline.bas presentation.bas build/observer.bas > $@
