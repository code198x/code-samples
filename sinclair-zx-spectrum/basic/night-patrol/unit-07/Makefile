# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: sight-changes.tap

sight-changes.tap: ../teaching/data/sight-changes.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f sight-changes.tap

.PHONY: all clean
