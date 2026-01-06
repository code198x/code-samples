# Unit 1: The Board

Basic screen setup and board drawing with attribute memory.

## What This Unit Covers

- ZX Spectrum screen memory organisation
- Attribute memory for colour control
- ROM routine usage (RST 16 for character output)
- Border colour via OUT instruction
- Direct attribute memory writes

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator or real hardware. An 8x8 game board is displayed with white cells.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Attribute memory | 768 bytes at 22528 ($5800) control colours |
| Colour encoding | Paper (bits 3-5) + Ink (bits 0-2) |
| RST 16 | ROM routine to print character at cursor |
| Border OUT | Port 254 controls border colour |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
