# Makefile for Pixel Patrol - Lesson 3
# C64 Assembly game build system

# Project settings
PROJECT_NAME = pixel-patrol-03
SOURCE_FILE = $(PROJECT_NAME).asm
BUILD_DIR = build
PRG_FILE = $(BUILD_DIR)/$(PROJECT_NAME).prg
D64_FILE = $(BUILD_DIR)/$(PROJECT_NAME).d64

# Tool settings
ASSEMBLER = acme
ACME_FLAGS = -f cbm -o $(PRG_FILE) --cpu 6502 --format cbm
C1541 = c1541

# Default target
all: $(PRG_FILE)

# Build the PRG file
$(PRG_FILE): $(SOURCE_FILE) | $(BUILD_DIR)
	$(ASSEMBLER) $(ACME_FLAGS) $(SOURCE_FILE)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Create D64 disk image
disk: $(D64_FILE)

$(D64_FILE): $(PRG_FILE)
	$(C1541) -format "pixel patrol,03" d64 $(D64_FILE)
	$(C1541) -attach $(D64_FILE) -write $(PRG_FILE) $(PROJECT_NAME)

# Run in VICE emulator
run: $(PRG_FILE)
	x64sc $(PRG_FILE)

# Run from disk
run-disk: $(D64_FILE)
	x64sc -autostart $(D64_FILE)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install acme vice

# Help
help:
	@echo "Available targets:"
	@echo "  all       - Build PRG file (default)"
	@echo "  disk      - Create D64 disk image"
	@echo "  run       - Run PRG in VICE emulator"
	@echo "  run-disk  - Run D64 in VICE emulator"
	@echo "  clean     - Remove build files"
	@echo "  install-deps - Install build dependencies"
	@echo "  help      - Show this help"

.PHONY: all disk run run-disk clean install-deps help