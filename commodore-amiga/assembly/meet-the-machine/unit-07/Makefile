# Commodore Amiga Makefile — family-native, deterministic toolchain
ASM ?= asm198x
BUILD ?= build198x
EMU ?= emu198x-amiga
SRC = copper.asm
EXE = copper
ADF = copper.adf
NAME = Copper

.PHONY: all run verify verify-full clean

all: $(ADF)

$(EXE): $(SRC)
	$(ASM) --dialect vasm --exe $(SRC) -o $(EXE)

$(ADF): $(EXE)
	$(BUILD) adf $(EXE) -o $(ADF) --volume $(NAME) --name $(EXE)

run: $(ADF)
	@test -n "$(KICKSTART)" || (echo "Set KICKSTART to a legally obtained Kickstart 1.3 ROM"; exit 1)
	$(EMU) --kickstart $(KICKSTART) --model a500 --disk $(ADF)

verify:
	python3 ../../../../_capture/verify.py capture/manifest.json --public

verify-full:
	python3 ../../../../_capture/verify.py capture/manifest.json --full

clean:
	rm -f $(EXE) $(ADF)
