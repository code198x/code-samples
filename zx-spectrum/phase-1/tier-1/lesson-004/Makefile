# Makefile for Quantum Shatter Lesson 4
# Collision Detection

# Tools
ASSEMBLER = sjasmplus
EMULATOR = fuse

# Files  
SOURCE = quantum-shatter-04.asm
OUTPUT = quantum-shatter-04.tap
BINARY = quantum-shatter-04.bin

# Build rules
all: $(OUTPUT)

$(OUTPUT): $(SOURCE)
	$(ASSEMBLER) --lst --lstlab $(SOURCE)

run: $(OUTPUT)
	$(EMULATOR) $(OUTPUT)

clean:
	rm -f $(OUTPUT) $(BINARY) *.lst

.PHONY: all run clean