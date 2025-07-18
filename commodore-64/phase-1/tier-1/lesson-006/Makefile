# Makefile for Pixel Patrol Lesson 6
# Sprite Grid Movement

# Tools
ACME = acme
X64SC = x64sc

# Build directory
BUILDDIR = build

# Files
SOURCE = pixel-patrol-06.asm
TARGET = $(BUILDDIR)/pixel-patrol-06.prg

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