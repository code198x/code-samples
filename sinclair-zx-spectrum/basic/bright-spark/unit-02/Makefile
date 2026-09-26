# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: restore.tap

restore.tap: ../opening/unit-02/experiments/restore.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f restore.tap

.PHONY: all clean
