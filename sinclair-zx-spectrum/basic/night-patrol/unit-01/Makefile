# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: night-patrol.tap

night-patrol.tap: ../teaching/archive/night-patrol.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f night-patrol.tap

.PHONY: all clean
