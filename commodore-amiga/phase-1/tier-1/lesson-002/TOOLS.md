# Real Amiga ADF Tools

## 1. amitools (Recommended)
The most comprehensive Python-based Amiga toolkit.

### Installation
```bash
# Via pip (Python 3.6+)
pip install amitools

# Or from source
git clone https://github.com/cnvogelg/amitools.git
cd amitools
pip install -e .
```

### Usage
```bash
# Create a formatted ADF
xdftool mydisk.adf create

# Format as OFS (Old File System)
xdftool mydisk.adf format "TurboHorizon" OFS

# Write files to ADF
xdftool mydisk.adf write turbo-horizon-01

# Make bootable (requires bootblock)
xdftool mydisk.adf boot install bootblock.bin

# List contents
xdftool mydisk.adf list
```

## 2. ADFlib
C library with command-line tools.

### Installation
```bash
# macOS with Homebrew
brew install adflib

# Build from source
git clone https://github.com/lclevy/ADFlib.git
cd ADFlib
make
```

### Usage
```bash
# Create and format ADF
unadf -c mydisk.adf
unadf -f mydisk.adf

# Copy files
unadf -p mydisk.adf turbo-horizon-01
```

## 3. FS-UAE Tools
Built into FS-UAE emulator.

### Installation
```bash
# macOS
brew install fs-uae

# Ubuntu/Debian
sudo apt-get install fs-uae

# Or download from https://fs-uae.net/
```

### Creating Bootable ADF with FS-UAE
```bash
# FS-UAE includes ADF creation in its launcher
fs-uae-launcher
# Then: Tools -> ADF Creator
```

## 4. WinUAE (Windows)
Has built-in ADF creation tools.
- Tools menu -> Create blank ADF
- Can format and install bootblock

## 5. GoADF
Modern Go implementation.

### Installation
```bash
go get github.com/maetthu/goadf
```

## Creating a Proper Bootable ADF

Here's a complete example using amitools:

```bash
# 1. Install amitools
pip install amitools

# 2. Create formatted ADF
xdftool turbo-horizon.adf create + format "TurboHorizon" OFS

# 3. Create a startup-sequence
echo "turbo-horizon-01" > startup-sequence

# 4. Create proper directory structure
xdftool turbo-horizon.adf mkdir s
xdftool turbo-horizon.adf write startup-sequence s/startup-sequence
xdftool turbo-horizon.adf write turbo-horizon-01

# 5. Install bootblock (optional - for direct boot)
# You'll need a proper bootblock binary
xdftool turbo-horizon.adf boot install mybootblock.bin

# 6. List contents to verify
xdftool turbo-horizon.adf list
```

## Creating a Workbench-Compatible Disk

For a disk that auto-runs from Workbench:

```bash
# 1. Create and format
xdftool wb-game.adf create + format "GameDisk" OFS

# 2. Create directory structure
xdftool wb-game.adf mkdir c
xdftool wb-game.adf mkdir s
xdftool wb-game.adf mkdir devs
xdftool wb-game.adf mkdir libs

# 3. Copy essential Workbench files (from a Workbench disk)
# You need: c/run, c/execute, libs/icon.library, etc.

# 4. Create startup-sequence
echo "turbo-horizon-01" > startup-sequence
xdftool wb-game.adf write startup-sequence s/startup-sequence

# 5. Add your game
xdftool wb-game.adf write turbo-horizon-01

# 6. Add icon file for Workbench (optional)
xdftool wb-game.adf write turbo-horizon-01.info
```

## Platform-Specific Notes

### macOS
```bash
# Best option: Install via Homebrew
brew install amitools
# or
brew install fs-uae  # Includes ADF tools
```

### Linux
```bash
# Ubuntu/Debian
sudo apt-get install python3-pip
pip3 install amitools

# Or use package manager
sudo apt-get install fs-uae fs-uae-launcher
```

### Windows
- WinUAE has the best integrated tools
- Or use amitools via Python:
```cmd
python -m pip install amitools
```

## Quick Start Script

Save this as `make-adf.sh`:

```bash
#!/bin/bash
# Requires: pip install amitools

if [ $# -eq 0 ]; then
    echo "Usage: $0 <executable>"
    exit 1
fi

EXE=$1
ADF="${EXE%.*}.adf"

# Create and format ADF
xdftool "$ADF" create + format "GameDisk" OFS

# Create s directory and startup-sequence
echo "$EXE" > startup-sequence
xdftool "$ADF" mkdir s
xdftool "$ADF" write startup-sequence s/startup-sequence
rm startup-sequence

# Copy executable
xdftool "$ADF" write "$EXE"

# List contents
echo "Created $ADF with contents:"
xdftool "$ADF" list

echo "To run: Boot Amiga with this disk, it will auto-start"
```

## Testing Your ADF

```bash
# With FS-UAE
fs-uae --floppy-drive-0=turbo-horizon.adf

# With WinUAE (Windows)
winuae -s floppy0=turbo-horizon.adf

# With vAmiga (macOS)
# Just drag the ADF to the emulator window
```

The most user-friendly approach is to install `amitools` via pip - it works on all platforms and provides everything you need to create proper AmigaDOS-formatted ADF files.