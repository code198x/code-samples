# Makefile for Quantum Shatter Lesson 1
# Creates animated starfield for ZX Spectrum

# sjasmplus Z80 assembler
ASM = sjasmplus

# Fuse Spectrum emulator - try open command for macOS
EMU = open -a Fuse

# Build directory
BUILDDIR = build

# Source and target files
SRC = quantum-shatter-01.asm
TAP = $(BUILDDIR)/quantum-shatter-01.tap

# Default target
all: $(TAP)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Assemble and create TAP file
$(TAP): $(SRC) | $(BUILDDIR)
	$(ASM) --lst=$(BUILDDIR)/quantum-shatter-01.lst --raw=$(BUILDDIR)/quantum-shatter-01.bin $(SRC)

# Run in emulator
run: $(TAP)
	$(EMU) $(TAP)

# Clean build files
clean:
	rm -rf $(BUILDDIR)

.PHONY: all run clean