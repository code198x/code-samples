# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: step-01.prg

step-01.prg: steps/step-01.bas
	$(BUILD198X) basic $< --machine commodore-c64 -o $@

clean:
	rm -f step-01.prg

.PHONY: all clean
