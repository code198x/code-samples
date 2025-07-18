# Makefile for Pixel Patrol Lesson 8
# Basic Game Loop

# Tools
ACME = acme
X64SC = x64sc

# Build directory
BUILDDIR = build

# Files
SOURCE = pixel-patrol-08.asm
TARGET = $(BUILDDIR)/pixel-patrol-08.prg

# Build rules
all: $(TARGET)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(TARGET): $(SOURCE) | $(BUILDDIR)
	$(ACME) -f cbm -o $(TARGET) $(SOURCE)

run: $(TARGET)
	$(X64SC) $(TARGET)

clean:
	rm -rf $(BUILDDIR)

.PHONY: all run clean