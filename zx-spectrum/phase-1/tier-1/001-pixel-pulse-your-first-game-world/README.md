# Lesson 1: Pixel Pulse - Your First Game World

This folder contains all the code examples for ZX Spectrum Lesson 1, which teaches Z80 assembly programming, screen memory manipulation, and the attribute color system.

## Files

- **`complete.z80`** - Full game arena with colorful borders and title display
- **`step1-basic.z80`** - Simple screen setup and title drawing
- **`step3-colors.z80`** - Color attribute system demonstration
- **`loader.bas`** - BASIC loader program for easy testing
- **`build.sh`** - Build script using PASMO assembler

## Building

All examples require PASMO assembler and an emulator like Fuse:

```bash
# Install PASMO (macOS)
brew install pasmo

# Install Fuse ZX Spectrum emulator
brew install fuse-emulator

# Make build script executable
chmod +x build.sh

# Build any example
./build.sh complete.z80

# Run in Fuse emulator
fuse complete.tap
```

## Manual Assembly

```bash
# Assemble Z80 source to TAP file
pasmo --tap complete.z80 complete.tap

# Or create binary for loading from BASIC
pasmo complete.z80 complete.bin
```

## Features Demonstrated

- **Z80 assembly language** fundamentals
- **Screen memory layout** ($4000-$57FF display, $5800-$5AFF attributes)
- **Character graphics** creation with bitmap data
- **Color attributes** using INK, PAPER, BRIGHT, and FLASH
- **BASIC integration** with LOAD "" CODE commands
- **Game arena creation** with borders and decorative elements
- **Keyboard input** handling with port reads

## ZX Spectrum Memory Map

- **$0000-$3FFF**: ROM (BASIC interpreter and system routines)
- **$4000-$57FF**: Screen bitmap (6144 bytes, 256×192 pixels)
- **$5800-$5AFF**: Color attributes (768 bytes, 32×24 characters)
- **$5B00-$FFFF**: Available RAM (programs load here)

## Screen Layout

The ZX Spectrum has a unique screen organization:
- **Display**: 256×192 pixels organized as 32×24 character cells
- **Attributes**: One color byte per 8×8 pixel character cell
- **Memory layout**: Non-linear arrangement for efficient vertical scrolling

## Color System

Each attribute byte controls an 8×8 character cell:
- **Bits 0-2**: INK color (foreground, 0-7)
- **Bits 3-5**: PAPER color (background, 0-7)  
- **Bit 6**: BRIGHT flag (normal/bright colors)
- **Bit 7**: FLASH flag (steady/flashing display)

## What You'll See

- **Clear screen** with cyan border
- **"PIXEL PULSE" title** drawn with custom bitmap characters
- **Colorful arena borders** using different color combinations
- **Rainbow effects** and flashing elements
- **Keyboard response** - press any key to continue

## Key Concepts

### Character Drawing

Custom 8×8 character bitmaps:
```z80
letter_p:
    DB %11111000
    DB %10001000  
    DB %10001000
    DB %11111000
    DB %10000000
    DB %10000000
    DB %10000000
    DB %00000000
```

### Screen Address Calculation

ZX Spectrum screen memory is complex:
```z80
; Calculate screen address for Y,X coordinate
LD A, B         ; Y coordinate
AND 7           ; Y mod 8 (pixel row in character)
RRCA            ; Multiply by 32
RRCA
RRCA
LD L, A         ; Low byte
```

### Color Attributes

Setting character cell colors:
```z80
; Set cyan ink on blue paper
LD D, INK_CYAN + PAPER_BLUE + BRIGHT
CALL set_attribute
```

## Controls

- **Any key** - Continue from title screen to game arena
- **SPACE** - Exit back to BASIC (in some examples)

## Game Arena Features

- **Border walls** in cyan on blue
- **Playing field** in green on black  
- **Decorative corners** with special effects
- **Title display** with rainbow colors
- **Flashing elements** for visual appeal

## Common Issues

1. **Black screen**: Check that program loads at correct address ($8000)
2. **Wrong colors**: Verify attribute memory calculations
3. **Garbled display**: Ensure screen memory writes are correct
4. **Loading errors**: Use proper BASIC LOAD "" CODE syntax

## BASIC Loading

Load and run from BASIC:
```basic
LOAD "complete" CODE 32768
RANDOMIZE USR 32768
```

Or use the included loader:
```basic
LOAD "loader"
RUN
```

## Next Steps

This foundation prepares you for:
- Player character creation and movement
- Enemy AI and collision detection  
- Sound effects using the beeper
- Scrolling backgrounds
- Full game development

Perfect introduction to ZX Spectrum assembly programming! 🕹️💾