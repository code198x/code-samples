#!/bin/bash
# Build script for Amiga Crystal Cascade examples

echo "Building Crystal Cascade Amiga examples..."

# Check if vasmm68k_mot is installed
if ! command -v vasmm68k_mot &> /dev/null; then
    echo "Error: vasmm68k_mot not found. Please install VASM first."
    echo "See README.md for installation instructions."
    exit 1
fi

# Build all assembly files
for file in *.s; do
    if [ -f "$file" ]; then
        base="${file%.s}"
        echo "Assembling $file -> $base"
        vasmm68k_mot -Fhunkexe -o "$base" "$file"
        if [ $? -eq 0 ]; then
            echo "  Success: $base created"
        else
            echo "  Error: Failed to build $file"
        fi
    fi
done

# Option: Create ADF disk image with all executables
if command -v adfcreate &> /dev/null; then
    echo ""
    echo "Creating ADF disk image..."
    
    # Remove old ADF if exists
    rm -f crystal-cascade.adf
    
    # Create new ADF
    adfcreate crystal-cascade.adf
    
    # Copy all executables to ADF
    for exe in complete step1-minimal step3-bitplanes step7-parallax; do
        if [ -f "$exe" ]; then
            echo "Adding $exe to ADF..."
            adfcopy crystal-cascade.adf "$exe" /
        fi
    done
    
    echo "ADF created: crystal-cascade.adf"
    echo "Mount this in FS-UAE as DF1: to access all examples"
else
    echo ""
    echo "Note: Install ADFlib to automatically create an ADF disk image"
    echo "Build from source:"
    echo "  git clone https://github.com/lclevy/ADFlib.git"
    echo "  cd ADFlib && ./autogen.sh && ./configure && make && sudo make install"
fi

echo ""
echo "Build complete! To run in FS-UAE, see README.md for transfer options."