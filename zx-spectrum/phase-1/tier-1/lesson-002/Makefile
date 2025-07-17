# Makefile for Quantum Shatter Lesson 2
# Creates controllable player ship for ZX Spectrum

# SjASMPlus assembler
AS = sjasmplus

# Fuse ZX Spectrum emulator
EMU = fuse

# Build directory
BUILDDIR = build

# Source and target files
SRC = quantum-shatter-02.asm
TAP = $(BUILDDIR)/quantum-shatter-02.tap

# Default target
all: $(TAP)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Assemble the TAP file
$(TAP): $(SRC) | $(BUILDDIR)
	$(AS) $(SRC)

# Run in emulator
run: $(TAP)
	$(EMU) --tape $(TAP)

# Clean build files
clean:
	rm -rf $(BUILDDIR)

.PHONY: all run clean