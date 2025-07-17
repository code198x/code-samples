# Makefile for Turbo Horizon Lesson 2
# Creates hardware sprite-based player ship for Amiga

# vasm assembler for 68000
AS = vasmm68k_mot
ASFLAGS = -Fhunkexe -nosym -kick1hunks

# FS-UAE Amiga emulator
EMU = fs-uae

# Build directory
BUILDDIR = build

# Source and target files
SRC = turbo-horizon-02.s
EXE = $(BUILDDIR)/turbo-horizon-02

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
$(BUILDDIR)/turbo-horizon.adf: $(EXE) make-adf.sh
	@echo "Creating ADF disk image..."
	./make-adf.sh $(EXE) $(BUILDDIR)/turbo-horizon.adf

# Run in emulator
run: $(BUILDDIR)/turbo-horizon.adf $(EMUCONFIG)
	@echo "Running in emulator..."
	@echo "To start: $(EMU) $(EMUCONFIG)"
	@echo "Then from Workbench or CLI, run: turbo-horizon-02"

# Clean build files
clean:
	rm -rf $(BUILDDIR)
	rm -f $(EMUCONFIG)

# Help message
help:
	@echo "Turbo Horizon Lesson 2 - Makefile targets:"
	@echo "  make         - Build the executable"
	@echo "  make run     - Build and prepare for emulator"
	@echo "  make clean   - Remove build files"
	@echo "  make install-tools - Show how to install ADF tools"
	@echo ""
	@echo "Requirements:"
	@echo "  - vasmm68k_mot (68k assembler)"
	@echo "  - amitools (optional, for proper ADF creation)"
	@echo "  - FS-UAE or similar emulator"

# Show tool installation instructions
install-tools:
	@echo "To install the recommended tools:"
	@echo ""
	@echo "1. vasm (required):"
	@echo "   Download from: http://sun.hasenbraten.de/vasm/"
	@echo ""
	@echo "2. amitools (recommended for proper ADFs):"
	@echo "   pip install amitools"
	@echo "   or"
	@echo "   pip3 install amitools"
	@echo ""
	@echo "3. FS-UAE (emulator):"
	@echo "   macOS:  brew install fs-uae"
	@echo "   Linux:  sudo apt-get install fs-uae"
	@echo "   Windows: Download from https://fs-uae.net/"
	@echo ""
	@echo "See TOOLS.md for more details."

.PHONY: all run clean help install-tools