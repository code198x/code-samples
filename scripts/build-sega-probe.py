"""Finish the standard Sega cartridge checksum; refuse malformed output."""

import sys
from pathlib import Path

path = Path(sys.argv[1])
rom = bytearray(path.read_bytes())
if len(rom) != 32768 or rom[0x7FF0:0x7FF8] != b"TMR SEGA":
    raise SystemExit("Expected a 32 KiB Sega probe with header at $7FF0")
rom[0x7FFA:0x7FFC] = (sum(rom[:0x7FF0]) & 65535).to_bytes(2, "little")
path.write_bytes(rom)
