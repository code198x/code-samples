# Makefile for Underground Assault - Lesson 3
# NES Assembly game build system

# Project settings
PROJECT_NAME = underground-assault-03
SOURCE_FILE = $(PROJECT_NAME).s
BUILD_DIR = build
NES_FILE = $(BUILD_DIR)/$(PROJECT_NAME).nes
NSF_FILE = $(BUILD_DIR)/$(PROJECT_NAME).nsf

# Tool settings
ASSEMBLER = ca65
LINKER = ld65
CA65_FLAGS = -g -o $(BUILD_DIR)/$(PROJECT_NAME).o
LD65_FLAGS = -C nes.cfg -o $(NES_FILE)

# Default target
all: $(NES_FILE)

# Build the NES file
$(NES_FILE): $(SOURCE_FILE) | $(BUILD_DIR)
	$(ASSEMBLER) $(CA65_FLAGS) $(SOURCE_FILE)
	$(LINKER) $(LD65_FLAGS) $(BUILD_DIR)/$(PROJECT_NAME).o

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Run in FCEUX emulator
run: $(NES_FILE)
	fceux $(NES_FILE)

# Run in Nestopia emulator
run-nestopia: $(NES_FILE)
	nestopia $(NES_FILE)

# Run in Mesen emulator
run-mesen: $(NES_FILE)
	mesen $(NES_FILE)

# Test build only (no emulator)
test: $(NES_FILE)
	@echo "Build successful: $(NES_FILE)"
	@ls -la $(NES_FILE)

# Debug build with symbols
debug: $(SOURCE_FILE) | $(BUILD_DIR)
	$(ASSEMBLER) -g --debug-info -o $(BUILD_DIR)/$(PROJECT_NAME).o $(SOURCE_FILE)
	$(LINKER) $(LD65_FLAGS) --dbgfile $(BUILD_DIR)/$(PROJECT_NAME).dbg $(BUILD_DIR)/$(PROJECT_NAME).o

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install cc65 fceux

# Install dependencies (macOS)
install-deps-mac:
	brew install cc65
	brew install fceux

# Help
help:
	@echo "Available targets:"
	@echo "  all       - Build NES file (default)"
	@echo "  run       - Run in FCEUX emulator"
	@echo "  run-nestopia - Run in Nestopia emulator"
	@echo "  run-mesen - Run in Mesen emulator"
	@echo "  test      - Test build without running"
	@echo "  debug     - Build with debug symbols"
	@echo "  clean     - Remove build files"
	@echo "  install-deps - Install build dependencies (Linux)"
	@echo "  install-deps-mac - Install dependencies (macOS)"
	@echo "  help      - Show this help"

.PHONY: all run run-nestopia run-mesen test debug clean install-deps install-deps-mac help