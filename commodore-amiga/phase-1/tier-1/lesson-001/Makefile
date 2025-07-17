# Makefile for Turbo Horizon Lesson 1
# Creates animated starfield for Amiga

# vasm assembler for 68000
AS = vasmm68k_mot
ASFLAGS = -Fhunkexe -nosym -kick1hunks

# FS-UAE Amiga emulator
EMU = fs-uae

# Build directory
BUILDDIR = build

# Source and target files
SRC = turbo-horizon-01.s
EXE = $(BUILDDIR)/turbo-horizon-01

# Emulator config
EMUCONFIG = fs-uae.conf

# Default target
all: $(EXE)

# Create build directory
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Assemble the executable
$(EXE): $(SRC) | $(BUILDDIR)
	$(AS) $(ASFLAGS) -o $(EXE) $(SRC)

# Create emulator config if it doesn't exist
$(EMUCONFIG):
	@echo "Creating FS-UAE config..."
	@echo "amiga_model = A500" > $(EMUCONFIG)
	@echo "kickstart_file = kick13.rom" >> $(EMUCONFIG)
	@echo "floppy_drive_0 = $(BUILDDIR)/turbo-horizon.adf" >> $(EMUCONFIG)
	@echo "window_width = 640" >> $(EMUCONFIG)
	@echo "window_height = 512" >> $(EMUCONFIG)

# Create ADF disk image with executable
$(BUILDDIR)/turbo-horizon.adf: $(EXE) create_adf.py
	@echo "Creating ADF disk image..."
	python3 create_adf.py $(EXE) $(BUILDDIR)/turbo-horizon.adf

# Run in emulator
run: $(BUILDDIR)/turbo-horizon.adf $(EMUCONFIG)
	@echo "Running in emulator..."
	@echo "To start: $(EMU) $(EMUCONFIG)"
	@echo "Then from Workbench or CLI, run: turbo-horizon-01"

# Clean build files
clean:
	rm -rf $(BUILDDIR)
	rm -f $(EMUCONFIG)

.PHONY: all run clean