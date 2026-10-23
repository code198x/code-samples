SHARED = ../../../../../commodore-64/patterns/basic/framework/turn-deadline
PRESENTATION = presentation.bas
.PHONY: all
all: build/demo.bas build/customise.bas build/wrong.bas
build/observer.bas: $(SHARED)/monitor.bas
	mkdir -p build
	awk '$$1 >= 9000' $< > $@
build/demo.bas: caller.bas $(SHARED)/routines.bas $(SHARED)/clock.bas $(SHARED)/../command-loop/routines.bas $(PRESENTATION) build/observer.bas
	cat caller.bas $(SHARED)/../command-loop/routines.bas $(SHARED)/routines.bas $(SHARED)/clock.bas $(PRESENTATION) build/observer.bas > $@
build/customise.bas: customise.bas $(SHARED)/routines.bas $(SHARED)/clock.bas $(SHARED)/../command-loop/routines.bas $(PRESENTATION) build/observer.bas
	cat customise.bas $(SHARED)/../command-loop/routines.bas $(SHARED)/routines.bas $(SHARED)/clock.bas $(PRESENTATION) build/observer.bas > $@
build/wrong.bas: caller.bas $(SHARED)/routines.bas $(SHARED)/mistakes/reset-baseline.bas $(SHARED)/../command-loop/routines.bas $(PRESENTATION) build/observer.bas
	cat caller.bas $(SHARED)/../command-loop/routines.bas $(SHARED)/routines.bas $(SHARED)/mistakes/reset-baseline.bas $(PRESENTATION) build/observer.bas > $@
