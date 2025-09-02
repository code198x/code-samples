# Makefile for Pixel Patrol Lesson 2
# C64 Assembly Development

# Project settings
PROJECT = pixel-patrol-02
TARGET = $(PROJECT).prg
SOURCE = $(PROJECT).asm

# Assembler settings (using ACME)
ACME = acme
ACME_FLAGS = -f cbm -o $(TARGET)

# Emulator settings
VICE = x64sc
VICE_FLAGS = -autostartprgmode 1

# Default target
all: $(TARGET)

# Build the PRG file
$(TARGET): $(SOURCE)
	$(ACME) $(ACME_FLAGS) $(SOURCE)

# Run in VICE emulator
run: $(TARGET)
	$(VICE) $(VICE_FLAGS) $(TARGET)

# Clean build artifacts
clean:
	rm -f $(TARGET)

# Development targets
test: run

# Show assembler output
verbose: 
	$(ACME) $(ACME_FLAGS) -v $(SOURCE)

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build the PRG file (default)"
	@echo "  run     - Build and run in VICE emulator"
	@echo "  test    - Same as run"
	@echo "  clean   - Remove build artifacts"
	@echo "  verbose - Build with verbose output"
	@echo "  help    - Show this help"

.PHONY: all run test clean verbose help