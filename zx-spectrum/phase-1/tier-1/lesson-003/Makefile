# Makefile for Quantum Shatter - Lesson 3
# ZX Spectrum Assembly game build system

# Project settings
PROJECT_NAME = quantum-shatter-03
SOURCE_FILE = $(PROJECT_NAME).asm
BUILD_DIR = build
TAP_FILE = $(BUILD_DIR)/$(PROJECT_NAME).tap
TZX_FILE = $(BUILD_DIR)/$(PROJECT_NAME).tzx

# Tool settings
ASSEMBLER = sjasmplus
SJASMPLUS_FLAGS = --lst=$(BUILD_DIR)/$(PROJECT_NAME).lst

# Default target
all: $(TAP_FILE)

# Build the TAP file
$(TAP_FILE): $(SOURCE_FILE) | $(BUILD_DIR)
	$(ASSEMBLER) $(SJASMPLUS_FLAGS) $(SOURCE_FILE)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Convert TAP to TZX for better emulator compatibility
tzx: $(TZX_FILE)

$(TZX_FILE): $(TAP_FILE)
	tape2wav $(TAP_FILE) $(BUILD_DIR)/temp.wav
	wav2tzx $(BUILD_DIR)/temp.wav $(TZX_FILE)
	rm -f $(BUILD_DIR)/temp.wav

# Run in Fuse emulator
run: $(TAP_FILE)
	fuse --auto-load $(TAP_FILE)

# Run in ZEsarUX emulator
run-zesarux: $(TAP_FILE)
	zesarux --tape $(TAP_FILE)

# Test build only (no emulator)
test: $(TAP_FILE)
	@echo "Build successful: $(TAP_FILE)"
	@ls -la $(TAP_FILE)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install sjasmplus fuse-emulator-utils

# Install dependencies (macOS)
install-deps-mac:
	brew install sjasmplus
	# Fuse can be installed manually from http://fuse-emulator.sourceforge.net/

# Help
help:
	@echo "Available targets:"
	@echo "  all       - Build TAP file (default)"
	@echo "  tzx       - Convert TAP to TZX format"
	@echo "  run       - Run in Fuse emulator"
	@echo "  run-zesarux - Run in ZEsarUX emulator"
	@echo "  test      - Test build without running"
	@echo "  clean     - Remove build files"
	@echo "  install-deps - Install build dependencies (Linux)"
	@echo "  install-deps-mac - Install dependencies (macOS)"
	@echo "  help      - Show this help"

.PHONY: all tzx run run-zesarux test clean install-deps install-deps-mac help