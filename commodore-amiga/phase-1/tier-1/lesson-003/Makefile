# Makefile for Turbo Horizon - Lesson 3
# Amiga Assembly game build system

# Project settings
PROJECT_NAME = turbo-horizon-03
SOURCE_FILE = $(PROJECT_NAME).s
BUILD_DIR = build
EXECUTABLE = $(BUILD_DIR)/$(PROJECT_NAME)
ADF_FILE = $(BUILD_DIR)/$(PROJECT_NAME).adf

# Tool settings
ASSEMBLER = vasmm68k_mot
ASSEMBLER_FLAGS = -Fhunkexe -nosym -kick1hunks -o $(EXECUTABLE)

# Default target
all: $(EXECUTABLE)

# Build the executable
$(EXECUTABLE): $(SOURCE_FILE) | $(BUILD_DIR)
	$(ASSEMBLER) $(ASSEMBLER_FLAGS) $(SOURCE_FILE)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Create ADF disk image
adf: $(ADF_FILE)

$(ADF_FILE): $(EXECUTABLE)
	@if command -v xdftool >/dev/null 2>&1; then \
		echo "Creating ADF with xdftool (amitools)..."; \
		xdftool "$(ADF_FILE)" format "TurboHorizon"; \
		xdftool "$(ADF_FILE)" makedir s; \
		echo "$(PROJECT_NAME)" > startup-sequence; \
		xdftool "$(ADF_FILE)" write startup-sequence s/startup-sequence; \
		rm startup-sequence; \
		xdftool "$(ADF_FILE)" write "$(EXECUTABLE)" "$(PROJECT_NAME)"; \
		echo "Created $(ADF_FILE)"; \
	elif [ -f create_adf.py ]; then \
		echo "Using Python fallback..."; \
		python3 create_adf.py "$(EXECUTABLE)" "$(ADF_FILE)"; \
	else \
		echo "No ADF tools available. Install amitools: pip install amitools"; \
		exit 1; \
	fi

# Run in FS-UAE emulator
run: $(ADF_FILE)
	fs-uae --floppy-drive-0="$(ADF_FILE)"

# Run in WinUAE (if available)
run-winuae: $(ADF_FILE)
	winuae -s floppy0="$(ADF_FILE)"

# Test build only (no emulator)
test: $(EXECUTABLE)
	@echo "Build successful: $(EXECUTABLE)"
	@ls -la $(EXECUTABLE)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install vasm-m68k-mot fs-uae

# Install dependencies (macOS)
install-deps-mac:
	brew install vasm fs-uae
	pip install amitools

# Help
help:
	@echo "Available targets:"
	@echo "  all       - Build executable (default)"
	@echo "  adf       - Create ADF disk image"
	@echo "  run       - Run in FS-UAE emulator"
	@echo "  run-winuae - Run in WinUAE emulator"
	@echo "  test      - Test build without running"
	@echo "  clean     - Remove build files"
	@echo "  install-deps - Install build dependencies (Linux)"
	@echo "  install-deps-mac - Install dependencies (macOS)"
	@echo "  help      - Show this help"

.PHONY: all adf run run-winuae test clean install-deps install-deps-mac help