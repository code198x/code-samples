# Makefile for Cosmic Harvester Lesson 4
# Collision Detection

# Tools
ACME = acme
X64 = x64

# Files
SOURCE = cosmic-harvester-04.asm
TARGET = cosmic-harvester-04.prg

# Build rules
all: $(TARGET)

$(TARGET): $(SOURCE)
	$(ACME) -o $(TARGET) $(SOURCE)

run: $(TARGET)
	$(X64) $(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: all run clean