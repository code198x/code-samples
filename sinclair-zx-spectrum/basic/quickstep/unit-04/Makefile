# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: quickstep.tap

quickstep.tap: ../teaching/clock/quickstep.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f quickstep.tap

.PHONY: all clean
