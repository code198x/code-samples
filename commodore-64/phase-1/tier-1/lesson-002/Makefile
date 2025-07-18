# Makefile for Pixel Patrol Lesson 2
# First Hardware Sprite

# ACME cross-assembler
ASM = acme

# VICE C64 emulator
EMU = x64sc

# Build directory
BUILDDIR = build

# Source and target files
SRC = pixel-patrol-02.asm
PRG = $(BUILDDIR)/pixel-patrol-02.prg

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