# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: step-03.tap

step-03.tap: ../opening/unit-03/steps/step-03.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f step-03.tap

.PHONY: all clean
