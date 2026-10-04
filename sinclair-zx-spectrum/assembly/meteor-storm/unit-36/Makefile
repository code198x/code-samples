# Build the tape this unit's lesson makes (loading-screen), the same tape unit 35 makes: a BASIC loader, the
# loading screen and the game, in that order. Their sources live in
# checkpoints/loading-screen/; this folder exists so the site can stage the tape
# where the lesson looks for it.
ASM ?= asm198x
BUILD198X ?= build198x
SRC = ../checkpoints/loading-screen
ASMFLAGS = --dialect pasmo --cpu z80 --tap

all: meteor-storm.tap

# The tape shows each block's name: --name sets the loader's; asm198x takes
# the others from the output file, so they are built in build/ as screen and
# storm.
build/meteor.tap: $(SRC)/loader.bas
	mkdir -p build
	$(BUILD198X) basic $< --machine sinclair-zx-spectrum -o $@ --name meteor

build/screen: $(SRC)/screen.asm $(SRC)/meteor-storm.scr
	mkdir -p build
	cd build && $(ASM) $(ASMFLAGS) $(abspath $<) -o screen

build/storm: $(SRC)/meteor-storm.asm $(wildcard $(SRC)/*.inc)
	mkdir -p build
	cd build && $(ASM) $(ASMFLAGS) $(abspath $<) -o storm

# A .tap file is its blocks one after another, so the tape is the three joined.
meteor-storm.tap: build/meteor.tap build/screen build/storm
	cat $^ > $@

clean:
	rm -rf build meteor-storm.tap

.PHONY: all clean
