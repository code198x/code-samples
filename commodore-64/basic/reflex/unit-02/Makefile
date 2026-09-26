# Build the program this unit's lesson shows, under its own name, so the
# lesson's run strip runs exactly the listing on the page.
BUILD198X ?= build198x

all: wait.prg

wait.prg: wait.bas
	$(BUILD198X) basic $< --machine commodore-c64 -o $@

clean:
	rm -f wait.prg

.PHONY: all clean
