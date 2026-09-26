# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: step-04.tap

step-04.tap: ../teaching/unit-09/steps/step-04.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f step-04.tap

.PHONY: all clean
