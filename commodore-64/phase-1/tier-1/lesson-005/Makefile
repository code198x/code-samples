# Makefile for Pixel Patrol Lesson 5
# Grid Position System

# Tools
ACME = acme
X64SC = x64sc

# Build directory
BUILDDIR = build

# Files
SOURCE = pixel-patrol-05.asm
TARGET = $(BUILDDIR)/pixel-patrol-05.prg

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