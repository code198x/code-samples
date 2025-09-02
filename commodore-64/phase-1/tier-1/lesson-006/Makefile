# Makefile for Grid Protocol Lesson 6
# Sector Boundary Alerts

# Tools
ACME = acme
X64SC = x64sc

# Files
SOURCE = grid-protocol-06.asm
TARGET = grid-protocol-06.prg

# Assembler flags
ACME_FLAGS = -f cbm -o $(TARGET)

# Build rules
all: $(TARGET)

$(TARGET): $(SOURCE)
	$(ACME) $(ACME_FLAGS) $(SOURCE)

run: $(TARGET)
	$(X64SC) -autostartprgmode 1 $(TARGET)

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