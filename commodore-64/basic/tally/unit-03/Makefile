# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: count.prg

count.prg: count.bas
	$(BUILD198X) basic $< --machine commodore-c64 -o $@

clean:
	rm -f count.prg

.PHONY: all clean
