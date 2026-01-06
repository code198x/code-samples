# Unit 1: The Stage

Basic screen setup, keyboard input, and SID gate control.

## What This Unit Covers

- VIC-II screen and colour RAM initialisation
- Drawing text and UI elements to screen memory
- CIA keyboard matrix scanning (X key)
- SID voice configuration (ADSR, frequency, pulse width)
- Gate on/off control for sound playback

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Press **X** to play a note.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Screen RAM ($0400) | 1000 bytes of character codes for display |
| Colour RAM ($D800) | Per-character colour attributes |
| CIA1 keyboard | Column select via $DC00, row read via $DC01 |
| SID gate bit | Bit 0 of control register triggers note |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
