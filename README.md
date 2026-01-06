# Code Like It's 198x - Code Samples

This repository contains all downloadable code samples for the Code Like It's 198x educational platform.

## Structure

Code samples are organized by platform and game project:

```
code-samples/
  ├── commodore-64/
  │   └── game-NN-[title]/
  │       └── unit-NN/
  │           ├── [project].asm
  │           └── [project].prg
  ├── sinclair-zx-spectrum/
  ├── nintendo-entertainment-system/
  ├── commodore-amiga/
  └── [other systems]/
```

## Current Content

### Commodore 64 - Game 1: SID Symphony

Complete assembly code samples for all 16 units of the rhythm game tutorial:

- **Units 01-04**: Screen layout, character graphics, and top/bottom panels.
- **Units 05-08**: SID chip fundamentals, voices, ADSR, and waveforms.
- **Units 09-12**: Keyboard input and rhythm mechanics.
- **Units 13-16**: Game loop integration, scoring, and polish.

All code has been tested and verified working in VICE emulator.

### Nintendo Entertainment System - Game 1: Neon Nexus
- **Units 01-16**: Movement, collision, HUD, SFX/music, title, high score, pause, and final polish. Build with ca65/ld65 (see unit `nexus.asm` for the config path).

### Sinclair ZX Spectrum - Game 1: Ink War
- **Units 01-16**: Board setup, cursor/input, AI vs hotseat, scoring/SFX, title, difficulty selection, visual polish, and final release TAPs (`pasmo --tapbas inkwar.asm inkwar.tap`).

### Commodore Amiga - Game 1: Hop
- **Units 01-16**: Bitplane/sprite setup, traffic/logs, collisions, lives, SFX, title screen blocks, and final polish. Build with `vasmm68k_mot -Fhunkexe -kick1hunks -o hop -nosym hop.asm` (package into ADF as needed).

## Building the Code

### Commodore 64 Assembly

Requirements:
- ACME assembler
- VICE emulator (x64sc)

```bash
# Assemble
acme -f cbm -o output.prg input.asm

# Run in VICE
x64sc output.prg
```

## License

Educational use - see main website repository for full license information.

## Website

https://code198x.stevehill.xyz
