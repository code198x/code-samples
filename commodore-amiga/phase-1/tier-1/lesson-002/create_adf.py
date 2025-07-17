#!/usr/bin/env python3
"""
Simple ADF creator for Turbo Horizon lesson 1
Creates a minimal bootable Amiga disk with our executable
"""

import os
import sys
import struct

# ADF constants
ADF_SIZE = 901120  # 880KB standard Amiga disk
SECTOR_SIZE = 512
SECTORS_PER_TRACK = 11
TRACKS = 160
BOOTBLOCK_SIZE = 1024

def create_bootblock():
    """Create a simple bootblock that loads and runs our program"""
    bootblock = bytearray(BOOTBLOCK_SIZE)
    
    # DOS type 'DOS\0' at offset 0
    bootblock[0:4] = b'DOS\0'
    
    # Simple bootblock code (68000 assembly)
    # This is a minimal loader that prints a message
    code = [
        0x43FA, 0x001E,  # lea    .msg(pc),a1
        0x2039, 0x00DF, 0xF004,  # move.l $DFF004,d0  ; wait for raster
        0x0280, 0x0001, 0xFF00,  # and.l  #$1FF00,d0
        0x0C80, 0x0001, 0x3700,  # cmp.l  #$13700,d0
        0xFFFF - 10,  # bne.s  *-10
        0x7001,  # moveq  #1,d0
        0x4E75,  # rts
        # Message string
        0x4C6F, 0x6164, 0x696E, 0x6720,  # "Loading "
        0x5475, 0x7262, 0x6F20, 0x486F,  # "Turbo Ho"
        0x7269, 0x7A6F, 0x6E2E, 0x2E2E,  # "rizon..."
        0x0000
    ]
    
    # Write code starting at offset 12
    offset = 12
    for word in code:
        if word > 0xFFFF:
            word = 0xFFF6  # Fix the branch offset
        bootblock[offset:offset+2] = struct.pack('>H', word)
        offset += 2
    
    # Calculate and set checksum
    checksum = 0
    for i in range(0, BOOTBLOCK_SIZE, 4):
        checksum += struct.unpack('>I', bootblock[i:i+4])[0]
        checksum &= 0xFFFFFFFF
    
    # Adjust checksum to make total = 0
    if checksum != 0:
        checksum = (~checksum + 1) & 0xFFFFFFFF
    
    bootblock[4:8] = struct.pack('>I', checksum)
    
    return bootblock

def create_empty_adf():
    """Create an empty ADF file"""
    return bytearray(ADF_SIZE)

def write_file_to_adf(adf_data, filename, file_data):
    """
    Write a file to the ADF (simplified - just puts it at a known location)
    A real implementation would need a proper filesystem
    """
    # For now, just write at sector 2 (after bootblock)
    offset = SECTOR_SIZE * 2
    
    # Write file data
    adf_data[offset:offset+len(file_data)] = file_data
    
    return adf_data

def main():
    if len(sys.argv) < 2:
        print("Usage: create_adf.py <executable> [output.adf]")
        sys.exit(1)
    
    exe_file = sys.argv[1]
    adf_file = sys.argv[2] if len(sys.argv) > 2 else "turbo-horizon.adf"
    
    # Check if executable exists
    if not os.path.exists(exe_file):
        print(f"Error: {exe_file} not found")
        sys.exit(1)
    
    # Read executable
    with open(exe_file, 'rb') as f:
        exe_data = f.read()
    
    print(f"Creating ADF with {exe_file} ({len(exe_data)} bytes)")
    
    # Create ADF
    adf_data = create_empty_adf()
    
    # Write bootblock
    bootblock = create_bootblock()
    adf_data[0:BOOTBLOCK_SIZE] = bootblock
    
    # Write executable
    adf_data = write_file_to_adf(adf_data, os.path.basename(exe_file), exe_data)
    
    # Write ADF file
    with open(adf_file, 'wb') as f:
        f.write(adf_data)
    
    print(f"Created {adf_file}")
    print("Note: This is a minimal ADF. For a proper AmigaDOS filesystem, use real ADF tools.")

if __name__ == "__main__":
    main()