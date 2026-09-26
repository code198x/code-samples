# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: brick-bash.tap

brick-bash.tap: ../teaching/unit-01/brick-bash.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f brick-bash.tap

.PHONY: all clean
