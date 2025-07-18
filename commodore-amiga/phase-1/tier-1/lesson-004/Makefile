# Makefile for Turbo Horizon Lesson 4
# Hardware Collision Detection

# Tools
ASM = vasmm68k_mot
ASMFLAGS = -Fhunkexe -nosym
TARGET = turbo-horizon-04

# Build rules
all: $(TARGET)

$(TARGET): $(TARGET).s
	$(ASM) $(ASMFLAGS) -o $(TARGET) $(TARGET).s

clean:
	rm -f $(TARGET)

# Create ADF disk image (requires xdftool)
disk: $(TARGET)
	xdftool turbo-horizon-04.adf create
	xdftool turbo-horizon-04.adf write $(TARGET)

.PHONY: all clean disk