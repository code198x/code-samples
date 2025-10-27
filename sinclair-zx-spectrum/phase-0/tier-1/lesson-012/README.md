# ZX Spectrum Lesson 012 - Character Movement

## Files

- `basic-movement.bas` - Simple QAOP character movement with boundary checking
- `smooth-mover.bas` - Enhanced movement with trail toggle, colour change, and graphics character

## Running the Code

### On Real Hardware
1. Switch on your ZX Spectrum
2. Type in the program line by line
3. Type `RUN` and press ENTER

### On Emulator (Fuse, ZXSpin, etc.)
1. Start the emulator
2. Type in the program or load the .bas file
3. Type `RUN` and press ENTER

## What It Does

### basic-movement.bas
Simple character movement system:
- QAOP keys control movement (Q=up, A=down, O=left, P=right)
- Boundary checking keeps character on screen
- Erase-and-redraw pattern for smooth movement
- Character represented by @ symbol

### smooth-mover.bas
Enhanced movement with extra features:
- Toggle trail mode (T key) - leaves dots behind or erases cleanly
- Change character colour (SPACE key)
- Uses CHR$ 144 (graphics character) instead of @
- Demonstrates state management with TRAIL variable

## Key Concepts

- **INKEY$** - Non-blocking keyboard input (returns empty string if no key)
- **QAOP** - Classic Spectrum keyboard layout (reachable with one hand)
- **Erase-and-redraw** - Print space at old position, character at new position
- **Boundary checking** - IF statements prevent leaving screen
- **State variables** - TRAIL and C variables track current mode and colour
- **CHR$** - Access to full character set including graphics characters

## Controls

### basic-movement.bas
- Q - Move up
- A - Move down
- O - Move left
- P - Move right

### smooth-mover.bas
- Q - Move up
- A - Move down
- O - Move left
- P - Move right
- T - Toggle trail on/off
- SPACE - Change colour

## Notes

- Screen coordinates: X (0-31 columns), Y (0-21 rows for playable area)
- INKEY$ checks keyboard without pausing program
- Old position (OX, OY) stored before movement for clean erasing
- CHR$ 144 is a filled block character from Spectrum character set
- Boundary checks use inclusive ranges (X<0, X>31, Y<3, Y>21)
