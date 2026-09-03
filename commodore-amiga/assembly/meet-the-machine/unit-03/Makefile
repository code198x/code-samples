# Commodore Amiga Makefile — family-native, deterministic toolchain
ASM ?= asm198x
BUILD ?= build198x
SRC = sizes.asm
EXE = sizes
ADF = sizes.adf
NAME = MeetTheMachine

.PHONY: all run clean

all: $(ADF)

# Asm198x's vasm dialect emits the Amiga hunk executable that AmigaDOS loads,
# matching `vasmm68k_mot -Fhunkexe -kick1hunks -nosym`.
$(EXE): $(SRC)
	$(ASM) --dialect vasm --exe $(SRC) -o $(EXE)

# Build198x masters the bootable OFS floppy: boot block, s/startup-sequence,
# and the executable. Same bytes on every run, unlike a wall-clock timestamp.
$(ADF): $(EXE)
	$(BUILD) adf $(EXE) -o $(ADF) --volume $(NAME) --name $(EXE)

run: $(ADF)
	fs-uae --floppy_drive_0=$(ADF)

clean:
	rm -f $(EXE) $(ADF)
