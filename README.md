# Code Like It's 198x - Code Samples

This repository contains all downloadable code samples for the Code Like It's 198x educational platform.

## Structure

Code samples are organized to match the website structure:

```
code-samples/
  ├── commodore-64/
  │   ├── basic/
  │   │   └── week-N/
  │   │       └── lesson-NN/
  │   └── assembly/
  │       └── week-N/
  │           └── lesson-NN/
  ├── sinclair-zx-spectrum/
  ├── nintendo-entertainment-system/
  ├── commodore-amiga/
  └── [other systems]/
```

## Current Content

### Commodore 64 - BASIC Week 1

The complete "Number Hunter" game from Lesson 8:
- Number guessing game with score tracking
- Input validation and hints
- Color-coded visual feedback
- Replay functionality

Files provided as `.bas` text - see `commodore-64/basic/README.md` for usage instructions (type in, paste, or convert to `.prg`).

### Commodore 64 - Assembly Week 1

Complete code samples for all 8 lessons of the Skyfall game tutorial:

- **Lesson 1**: Hello, Assembly! - Basic program structure and border color
- **Lesson 2**: Screen Memory - Writing characters directly to screen RAM (3 progressive samples)
- **Lesson 3**: The Player Character - Drawing a character at a specific position
- **Lesson 4**: Subroutines - Screen setup and code organization
- **Lesson 5**: Reading the Keyboard - Detecting A and D key presses
- **Lesson 6**: Moving the Player - Basic left/right movement
- **Lesson 7**: Timing and Smooth Movement - Frame-based movement control
- **Lesson 8**: Responsive Controls - Input priority and polish

All code has been tested and verified working in VICE emulator.

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

## Corrections Applied

All code samples include corrections discovered during testing:

1. **Character Code**: Uses `$1E` (upward wedge) instead of `$5E` (pi symbol)
2. **Keyboard Matrix**: Correct values for A and D keys
   - A key: column `%11111101`, bit `%00000100`
   - D key: column `%11111011`, bit `%00000100`
3. **Hex Calculations**: Fixed address math in Lesson 2

## License

Educational use - see main website repository for full license information.

## Website

https://code198x.stevehill.xyz
