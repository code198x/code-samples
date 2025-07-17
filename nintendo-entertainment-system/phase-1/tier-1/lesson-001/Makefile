# Makefile for Underground Assault Lesson 1
# Creates animated starfield for NES

# ca65 assembler and ld65 linker
AS = ca65
LD = ld65

# FCEUX NES emulator
EMU = fceux

# Build directory
BUILDDIR = build

# Source files
SRC = underground-assault-01.s
OBJ = $(BUILDDIR)/underground-assault-01.o
ROM = $(BUILDDIR)/underground-assault-01.nes

# Linker configuration
CONFIG = nes.cfg

# Default target
all: $(ROM)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Assemble source to object file
$(OBJ): $(SRC) | $(BUILDDIR)
	$(AS) $(SRC) -o $(OBJ)

# Link object file to ROM
$(ROM): $(OBJ) $(CONFIG)
	$(LD) -C $(CONFIG) -o $(ROM) $(OBJ)

# Run in emulator
run: $(ROM)
	$(EMU) $(ROM)

# Clean build files
clean:
	rm -rf $(BUILDDIR)

.PHONY: all run clean