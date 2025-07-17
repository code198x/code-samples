# Makefile for Cosmic Harvester Lesson 1
# Build and run the starfield demo

# Program name
PROGRAM = cosmic-harvester-01

# Source files
SOURCES = $(PROGRAM).asm

# Build directory
BUILD_DIR = build

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Default target
all: $(BUILD_DIR) $(BUILD_DIR)/$(PROGRAM).prg

# Build the program
$(BUILD_DIR)/$(PROGRAM).prg: $(SOURCES) | $(BUILD_DIR)
	acme -f cbm -o $(BUILD_DIR)/$(PROGRAM).prg $(PROGRAM).asm

# Run in VICE emulator
run: $(BUILD_DIR)/$(PROGRAM).prg
	x64sc $(BUILD_DIR)/$(PROGRAM).prg

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Test build (same as all)
test: all

.PHONY: all run clean test