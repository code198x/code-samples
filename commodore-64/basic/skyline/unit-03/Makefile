# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: towers.prg

towers.prg: towers.bas
	$(BUILD198X) basic $< --machine commodore-c64 -o $@

clean:
	rm -f towers.prg

.PHONY: all clean
