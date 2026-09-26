# Build the legal step-01 listing this lesson shows. The page's last listing,
# meet-basic's step-03, uses the illegal name `name$` on purpose to show the
# ROM refusing it, so it cannot build; the run strip runs step-01 instead.
BUILD198X ?= build198x

all: step-01.tap

step-01.tap: ../../meet-basic/unit-04/steps/step-01.bas
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@

clean:
	rm -f step-01.tap

.PHONY: all clean
