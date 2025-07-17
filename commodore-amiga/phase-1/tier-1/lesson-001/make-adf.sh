#!/bin/bash
# Script to create a proper AmigaDOS ADF using amitools or fallback to Python

set -e

# Help user if xdftool isn't found
check_xdftool() {
    if ! command -v xdftool &> /dev/null; then
        echo "xdftool not found in PATH."
        echo ""
        echo "If you've installed amitools, you may need to:"
        echo "  - Add the pip bin directory to your PATH"
        echo "  - Use 'pipx install amitools' for automatic PATH setup"
        echo "  - Or activate your Python environment first"
        echo ""
        return 1
    fi
    return 0
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <executable> [output.adf]"
    exit 1
fi

EXE=$1
ADF=${2:-"turbo-horizon.adf"}

# Check if xdftool is available
if check_xdftool; then
    echo "Using xdftool (amitools) to create proper AmigaDOS ADF..."
    
    # Create and format ADF
    xdftool "$ADF" format "TurboHorizon"
    
    # Create s directory for startup-sequence
    xdftool "$ADF" makedir s
    
    # Create startup-sequence that runs our program
    echo "$EXE" > startup-sequence
    xdftool "$ADF" write startup-sequence s/startup-sequence
    rm startup-sequence
    
    # Copy executable
    xdftool "$ADF" write "$EXE"
    
    # Show contents
    echo "Created $ADF with contents:"
    xdftool "$ADF" list
    
    echo ""
    echo "This is a bootable AmigaDOS disk that will auto-run the program."
    
else
    echo "xdftool not found. Using Python fallback..."
    echo "For better results, install amitools: pip install amitools"
    echo ""
    
    # Use Python script as fallback
    if [ -f create_adf.py ]; then
        python3 create_adf.py "$EXE" "$ADF"
    else
        echo "Error: create_adf.py not found"
        exit 1
    fi
fi

echo ""
echo "To test in emulator:"
echo "  fs-uae --floppy-drive-0=$ADF"
echo "  or drag $ADF to your Amiga emulator"