# Cosmic Harvester - Lesson 1: Creating Your First Game World

This directory contains the complete source code for **Lesson 1** of the Cosmic Harvester game series.

## What This Code Does

Creates an animated starfield background with twinkling stars - the foundation for your space arcade game.

## Files Included

- `cosmic-harvester-01.asm` - Complete assembly source code
- `Makefile` - Build script for easy compilation
- `README.md` - This file

## Building the Program

### Option 1: Using Make (Recommended)
```bash
make            # Build the program
make run        # Build and run in VICE
make clean      # Clean build files
```

### Option 2: Manual Build
```bash
# Create build directory
mkdir -p build

# Assemble the program
acme -f cbm -o build/cosmic-harvester-01.prg cosmic-harvester-01.asm

# Run in VICE
x64sc build/cosmic-harvester-01.prg
```

## What You'll See

- **10 twinkling stars** scattered across a black screen
- **Animated colors** cycling through white, light gray, medium gray, and dark gray
- **Continuous animation** that loops forever

## Key Learning Points

### 6502 Assembly Concepts
- Program structure with BASIC headers
- Memory addressing modes
- Subroutine organization with JSR/RTS
- Loop construction with branches

### C64 Graphics Programming
- Screen memory layout ($0400-$07E7)
- Color memory layout ($D800-$DBE7)
- Character mode graphics
- PETSCII character codes

### Game Development Techniques
- Animated background effects
- Timing and delays for smooth animation
- Code organization for game systems

## Modifications to Try

1. **Add more stars**: Add additional star positions to `create_starfield`
2. **Change colors**: Modify the `twinkle_colors` data
3. **Adjust timing**: Change the delay values for different animation speeds
4. **Use different characters**: Try periods ($2E) or other PETSCII characters

## Next Steps

This starfield forms the foundation for Cosmic Harvester. In Lesson 2, you'll add:
- Player ship control
- Keyboard input handling
- Smooth movement systems

## Technical Notes

- **Memory Usage**: Uses screen memory for character display and color memory for character colors
- **Animation Method**: Color cycling rather than character movement for efficiency
- **Assembly**: Uses ACME assembler syntax with PETSCII character codes
- **Compatibility**: Runs on real C64 hardware and VICE emulator

## Troubleshooting

**"Command not found: acme"**
- Install ACME assembler or use the Docker development environment

**"Command not found: x64sc"**
- Install VICE emulator or use the Docker development environment

**No animation visible**
- Check that your emulator is running at normal speed (not warp mode)
- Verify the program assembled without errors

## Resources

- [C64 Memory Map](https://www.c64-wiki.com/wiki/Memory_Map)
- [PETSCII Character Set](https://www.c64-wiki.com/wiki/PETSCII)
- [ACME Assembler Documentation](https://sourceforge.net/projects/acme-crossass/)

Happy coding! 🚀