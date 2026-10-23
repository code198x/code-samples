.PHONY: all clean
all: build/demo.fth build/customise.fth build/wrong.fth
build/demo.fth: routines.fth clock.fth service.fth input.fth caller.fth settings.fth
	mkdir -p build
	cat routines.fth clock.fth service.fth input.fth caller.fth settings.fth > $@
	printf 'TURNS\n' >> $@
build/customise.fth: routines.fth clock.fth service.fth input.fth caller.fth customise.fth
	mkdir -p build
	cat routines.fth clock.fth service.fth input.fth caller.fth customise.fth > $@
	printf 'TURNS\n' >> $@
build/wrong.fth: routines.fth clock.fth mistakes/reset-baseline.fth input.fth caller.fth settings.fth
	mkdir -p build
	cat routines.fth clock.fth mistakes/reset-baseline.fth input.fth caller.fth settings.fth > $@
	printf 'TURNS\n' >> $@
clean:
	rm -f build/demo.fth build/customise.fth build/wrong.fth
