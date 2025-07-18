# Makefile for Pixel Patrol Lesson 4
# Grid-Based Movement System + Keyboard Matrix Testing

# Tools
ACME = acme
X64SC = x64sc

# Build directory
BUILDDIR = build

# Files
SOURCE = pixel-patrol-04.asm
TARGET = $(BUILDDIR)/pixel-patrol-04.prg

MATRIX_TEST_SOURCE = keyboard-matrix-test.asm
MATRIX_TEST_TARGET = $(BUILDDIR)/keyboard-matrix-test.prg

SIMPLE_TEST_SOURCE = simple-key-test.asm
SIMPLE_TEST_TARGET = $(BUILDDIR)/simple-key-test.prg

# Build rules
all: $(TARGET) $(MATRIX_TEST_TARGET) $(SIMPLE_TEST_TARGET)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(TARGET): $(SOURCE) | $(BUILDDIR)
	$(ACME) -f cbm -o $(TARGET) $(SOURCE)

$(MATRIX_TEST_TARGET): $(MATRIX_TEST_SOURCE) | $(BUILDDIR)
	$(ACME) -f cbm -o $(MATRIX_TEST_TARGET) $(MATRIX_TEST_SOURCE)

$(SIMPLE_TEST_TARGET): $(SIMPLE_TEST_SOURCE) | $(BUILDDIR)
	$(ACME) -f cbm -o $(SIMPLE_TEST_TARGET) $(SIMPLE_TEST_SOURCE)

run: $(TARGET)
	$(X64SC) $(TARGET)

test-matrix: $(MATRIX_TEST_TARGET)
	$(X64SC) $(MATRIX_TEST_TARGET)

test-simple: $(SIMPLE_TEST_TARGET)
	$(X64SC) $(SIMPLE_TEST_TARGET)

clean:
	rm -rf $(BUILDDIR)

.PHONY: all run test-matrix test-simple clean