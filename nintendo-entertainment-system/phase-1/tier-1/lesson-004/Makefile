# Makefile for Underground Assault Lesson 4
# Collision Detection

# Tools
CA65 = ca65
LD65 = ld65
FCEUX = fceux

# Files
SOURCE = underground-assault-04.s
OBJECT = underground-assault-04.o
TARGET = underground-assault-04.nes
CONFIG = nes.cfg

# Build rules
all: $(TARGET)

$(OBJECT): $(SOURCE)
	$(CA65) -o $(OBJECT) $(SOURCE)

$(TARGET): $(OBJECT)
	$(LD65) -C $(CONFIG) -o $(TARGET) $(OBJECT)

run: $(TARGET)
	$(FCEUX) $(TARGET)

clean:
	rm -f $(OBJECT) $(TARGET)

.PHONY: all run clean