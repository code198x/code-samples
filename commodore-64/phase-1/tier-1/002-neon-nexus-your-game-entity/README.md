# Lesson 2: Neon Nexus - Your Game Entity

This folder contains all the code examples for Lesson 2, which teaches player entity creation and positioning on the Commodore 64.

## Files

- **`complete.s`** - Complete program with positioned player entity
- **`step2-simple-player.s`** - Basic player character in top-left corner
- **`step3-centered-player.s`** - Player positioned at screen center

## Building

All examples require ACME assembler:

```bash
# Install ACME (macOS)
brew install acme

# Assemble any example
acme -f cbm -o player.prg complete.s

# Run in VICE emulator
x64sc player.prg
```

## Features Demonstrated

- **Game entity creation** with character placement
- **Screen coordinate math** (Y × 40 + X formula)
- **Indirect addressing** for flexible memory access
- **Color RAM manipulation** for character coloring
- **Variable-based positioning** using memory storage
- **Manual screen clearing** without KERNAL side effects

## Progression

Each file builds entity complexity:

1. **Step 2**: Simple fixed player in corner
2. **Step 3**: Player centered using position calculation
3. **Complete**: Dynamic positioning with variables and calculation subroutines

## What You'll See

- **Yellow diamond character** (player entity)
- **Positioned at screen center** (column 20, row 12)
- **Dark blue arena** background
- **Infinite game loop** (program keeps running)

## Key Concepts

- **Screen memory layout**: 40×25 character grid at $0400-$07E7
- **Color memory**: Parallel grid at $D800-$DBE7  
- **Position formula**: Address = $0400 + (Y × 40) + X
- **Zero page usage**: $FB-$FC for screen, $FD-$FE for color

This creates the foundation for any game object positioning system!