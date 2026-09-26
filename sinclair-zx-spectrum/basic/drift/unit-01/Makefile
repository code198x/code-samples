# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: drift.tap

drift.tap: ../teaching/draw-ship/drift.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f drift.tap

.PHONY: all clean
