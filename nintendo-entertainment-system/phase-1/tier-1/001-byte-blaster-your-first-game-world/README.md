# Lesson 1: Byte Blaster - Your First Game World

This folder contains all the code examples for NES Lesson 1, which teaches 6502 assembly programming, PPU graphics, and the tile-based rendering system on the Nintendo Entertainment System.

## Files

- **`complete.s`** - Full game arena with sprites, background tiles, and controller input
- **`step1-basic.s`** - Basic NES program structure and initialization
- **`step3-sprites.s`** - Sprite system implementation with OAM
- **`graphics.chr`** - Character ROM data (tiles and sprites)
- **`nes.inc`** - Standard NES definitions and constants
- **`build.sh`** - Build script using CC65 assembler and linker

## Building

All examples require CC65 development tools:

```bash
# Install CC65 (macOS)
brew install cc65

# Install Mesen emulator (recommended)
brew install --cask mesen

# Make build script executable
chmod +x build.sh

# Build any example
./build.sh complete.s

# Run in Mesen emulator
mesen complete.nes
```

## Manual Assembly

```bash
# Assemble source
ca65 complete.s -o complete.o

# Link to create NES ROM
ld65 complete.o -C nes.cfg -o complete.nes

# Run in emulator
mesen complete.nes
```

## Features Demonstrated

- **6502 assembly language** for NES development
- **NES program structure** with iNES header
- **PPU programming** for graphics display
- **Tile-based backgrounds** using nametables
- **Sprite system** with 64 hardware sprites
- **Controller input** reading with proper timing
- **VBlank timing** and NMI interrupt handling
- **Palette system** with 16 background and 16 sprite colors

## NES Architecture Overview

### CPU (2A03)
- **6502 processor** at ~1.79MHz
- **2KB internal RAM** at $0000-$07FF
- **Memory-mapped I/O** for PPU, APU, and controllers

### PPU (2C02)
- **Dedicated graphics processor**
- **Separate 16KB address space** for graphics data
- **256×240 pixel resolution**
- **Background**: 32×30 tiles (256×240 pixels)
- **Sprites**: 64 maximum, 8×8 or 8×16 pixels

### Memory Layout

**CPU Address Space:**
- `$0000-$07FF`: Internal RAM (2KB)
- `$2000-$2007`: PPU registers
- `$4000-$4017`: APU and I/O registers
- `$6000-$7FFF`: Battery-backed RAM (cartridge)
- `$8000-$FFFF`: Program ROM (cartridge)

**PPU Address Space:**
- `$0000-$1FFF`: Pattern tables (character data)
- `$2000-$2FFF`: Nametables (background layout)
- `$3F00-$3FFF`: Palette RAM

## What You'll See

- **NES startup sequence** with proper initialization
- **Colorful backgrounds** using 8×8 tiles
- **Player sprite** controllable with D-pad
- **Smooth movement** at 60 FPS
- **Game arena** with walls and playing field
- **Controller response** for all NES buttons

## Key Concepts

### iNES Header

Every NES ROM needs a proper header:
```asm6502
.segment "HEADER"
    .byte "NES", $1A    ; Magic number
    .byte 2             ; 2 × 16KB PRG ROM banks
    .byte 1             ; 1 × 8KB CHR ROM bank  
    .byte $01           ; Mapper 0, vertical mirroring
```

### PPU Initialization

Setting up graphics:
```asm6502
; Wait for PPU to stabilize
BIT $2002       ; Clear VBlank flag
vblankwait1:
    BIT $2002   ; Wait for VBlank
    BPL vblankwait1
```

### Sprite System

Hardware sprites using OAM:
```asm6502
; Sprite format: Y, Tile, Attributes, X
LDA #120        ; Y position
STA $0200       ; Sprite 0 Y
LDA #$10        ; Tile number
STA $0201       ; Sprite 0 tile
```

### Controller Reading

Reading NES controller:
```asm6502
; Strobe controller
LDA #1
STA $4016
LDA #0
STA $4016

; Read 8 buttons
LDX #8
controller_loop:
    LDA $4016   ; Read button
    LSR A       ; Shift to carry
    ROL buttons ; Store in variable
    DEX
    BNE controller_loop
```

## Controls

- **D-Pad** - Move player sprite around screen
- **A/B Buttons** - Future functionality (lessons 2+)
- **Start** - Future functionality
- **Select** - Future functionality

## Game Mechanics

- **Player movement**: 2 pixels per frame in any direction
- **Boundary checking**: Player cannot move off-screen
- **Smooth animation**: 60 FPS using VBlank timing
- **Tile-based arena**: Walls and playing field

## Graphics Format

### Pattern Tables
- **8×8 pixel tiles** stored as 2-bit planar format
- **2 pattern tables** of 256 tiles each
- **Background uses** pattern table 0
- **Sprites use** pattern table 1

### Palettes
- **4 background palettes** of 4 colors each
- **4 sprite palettes** of 4 colors each
- **52 total colors** available in NES palette

### CHR ROM Structure
The `graphics.chr` file contains:
- **$0000-$0FFF**: Background tiles (pattern table 0)
- **$1000-$1FFF**: Sprite tiles (pattern table 1)

## Common Issues

1. **Black screen**: Check PPU initialization and VBlank timing
2. **Garbled graphics**: Verify CHR ROM data and palette setup
3. **No sprites**: Ensure DMA transfer occurs during VBlank
4. **Input not working**: Check controller strobe sequence
5. **Emulator compatibility**: Test with multiple emulators

## Development Tools

### Required
- **CC65**: Assembler and linker for 6502
- **NES emulator**: Mesen, FCEUX, or Nestopia

### Optional
- **YY-CHR**: Character ROM editor
- **NEXXT**: Level editor and graphics tools
- **FamiTracker**: Music and sound effects

## Next Steps

This foundation prepares you for:
- **Advanced sprite animation** with multiple frames
- **Background scrolling** for larger game worlds
- **Sound effects** using the APU
- **Game logic** with enemies and collision
- **Multiple screens** and level progression

## File Dependencies

Make sure you have these files:
- `nes.inc` - NES system definitions
- `nes.cfg` - Linker configuration
- `graphics.chr` - Character ROM data

## Technical Notes

### VBlank Timing
- **NMI occurs** during VBlank (~2273 CPU cycles)
- **Graphics updates** must happen during VBlank
- **Game logic** runs during active display

### Memory Mappers
- Examples use **Mapper 0** (NROM)
- **No bank switching** - simplest setup
- **32KB PRG ROM** + **8KB CHR ROM** maximum

### Performance
- **1.79MHz CPU** requires efficient code
- **~29,780 cycles** per frame at 60 FPS
- **Sprite limit**: 8 sprites per scanline maximum

Perfect foundation for NES game development! 🎮🕹️