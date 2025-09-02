# Makefile for Grid Protocol Lesson 4
# C64 Assembly Development

# Project settings
PROJECT = grid-protocol-04
TARGET = $(PROJECT).prg
SOURCE = $(PROJECT).asm

# Test programs
MATRIX_TEST_SOURCE = keyboard-matrix-test.asm
MATRIX_TEST_TARGET = keyboard-matrix-test.prg
SIMPLE_TEST_SOURCE = simple-key-test.asm
SIMPLE_TEST_TARGET = simple-key-test.prg

# Assembler settings (using ACME)
ACME = acme
ACME_FLAGS = -f cbm

# Emulator settings
VICE = x64sc
VICE_FLAGS = -autostartprgmode 1

# Default target
all: $(TARGET)

# Build the main PRG file
$(TARGET): $(SOURCE)
	$(ACME) $(ACME_FLAGS) -o $(TARGET) $(SOURCE)

# Build test programs
$(MATRIX_TEST_TARGET): $(MATRIX_TEST_SOURCE)
	$(ACME) $(ACME_FLAGS) -o $(MATRIX_TEST_TARGET) $(MATRIX_TEST_SOURCE)

$(SIMPLE_TEST_TARGET): $(SIMPLE_TEST_SOURCE)
	$(ACME) $(ACME_FLAGS) -o $(SIMPLE_TEST_TARGET) $(SIMPLE_TEST_SOURCE)

# Run main program in VICE emulator
run: $(TARGET)
	$(VICE) $(VICE_FLAGS) $(TARGET)

# Run test programs
test-matrix: $(MATRIX_TEST_TARGET)
	$(VICE) $(VICE_FLAGS) $(MATRIX_TEST_TARGET)

test-simple: $(SIMPLE_TEST_TARGET)
	$(VICE) $(VICE_FLAGS) $(SIMPLE_TEST_TARGET)

# Clean build artifacts
clean:
	rm -f $(TARGET) $(MATRIX_TEST_TARGET) $(SIMPLE_TEST_TARGET)

# Development targets
test: run

# Show assembler output
verbose: 
	$(ACME) $(ACME_FLAGS) -v -o $(TARGET) $(SOURCE)

# Help target
help:
	@echo "Available targets:"
	@echo "  all         - Build all programs (default)"
	@echo "  run         - Build and run main program"
	@echo "  test-matrix - Build and run keyboard matrix test"
	@echo "  test-simple - Build and run simple key test"
	@echo "  test        - Same as run"
	@echo "  clean       - Remove build artifacts"
	@echo "  verbose     - Build with verbose output"
	@echo "  help        - Show this help"

.PHONY: all run test-matrix test-simple test clean verbose help