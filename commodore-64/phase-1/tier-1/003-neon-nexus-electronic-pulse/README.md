# Lesson 3: Neon Nexus - Electronic Pulse

This folder contains all the code examples for Lesson 3, which teaches player movement and keyboard input on the Commodore 64.

## Files

- **`complete.s`** - The final, complete program with all features
- **`step6-basic-movement.s`** - Basic WASD movement with delay system
- **`step8-raster-sync.s`** - Added raster synchronization and movement flag
- **`step9-proper-clearing.s`** - Fixed trail issue with proper position clearing
- **`step10-border-flash.s`** - Added visual feedback for boundary collisions

## Building

All examples require ACME assembler:

```bash
# Install ACME (macOS)
brew install acme

# Assemble any example
acme -f cbm -o movement.prg complete.s

# Run in VICE emulator
x64sc movement.prg
```

## Features Demonstrated

- **WASD keyboard input** using C64 keyboard matrix
- **Raster synchronization** for consistent timing
- **Movement delay system** for controllable speed  
- **Proper screen clearing** to prevent trails
- **Border flash feedback** for boundary hits
- **Efficient redraw system** using movement flags

## Progression

Each file builds upon the previous:

1. **Step 6**: Basic movement but runs too fast without raster sync
2. **Step 8**: Added proper timing and reduced flickering  
3. **Step 9**: Fixed the character trail issue
4. **Step 10**: Added satisfying visual feedback
5. **Complete**: Final polished version

## Controls

- **W** - Move up
- **A** - Move left  
- **S** - Move down
- **D** - Move right

The border flashes red when you hit screen boundaries.