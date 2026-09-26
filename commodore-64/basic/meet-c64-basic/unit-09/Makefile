# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: step-03.prg

step-03.prg: steps/step-03.bas
	$(BUILD198X) basic $< --machine commodore-c64 -o $@

clean:
	rm -f step-03.prg

.PHONY: all clean
