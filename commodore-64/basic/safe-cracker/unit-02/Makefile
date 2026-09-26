# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: guess.prg

guess.prg: guess.bas
	$(BUILD198X) basic $< --machine commodore-c64 -o $@

clean:
	rm -f guess.prg

.PHONY: all clean
