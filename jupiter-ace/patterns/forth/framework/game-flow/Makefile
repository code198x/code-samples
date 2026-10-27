.PHONY: all
all:
	mkdir -p build
	cat routines.fth reset.fth caller.fth settings.fth > build/working.fth
	cat demo.fth >> build/working.fth
	cp build/working.fth build/demo.fth
	cp build/working.fth build/repaired.fth
	cat routines.fth reset.fth caller.fth customise.fth > build/custom.fth
	cat demo.fth >> build/custom.fth
	cat routines.fth mistakes/reset-on-resume.fth caller.fth settings.fth > build/wrong.fth
	cat demo.fth >> build/wrong.fth
	cat routines.fth boundaries.fth > build/boundaries.fth
