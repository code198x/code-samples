# Makefile for Cosmic Harvester Lesson 2
# Adds player ship to starfield

# ACME cross-assembler
ASM = acme

# VICE C64 emulator
EMU = x64sc

# Build directory
BUILDDIR = build

# Source and target files
SRC = cosmic-harvester-02.asm
PRG = $(BUILDDIR)/cosmic-harvester-02.prg

# Default target
all: $(PRG)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Assemble the program
$(PRG): $(SRC) | $(BUILDDIR)
	$(ASM) -f cbm -o $(PRG) $(SRC)

# Run in emulator
run: $(PRG)
	$(EMU) $(PRG)

# Clean build files
clean:
	rm -rf $(BUILDDIR)

.PHONY: all run clean