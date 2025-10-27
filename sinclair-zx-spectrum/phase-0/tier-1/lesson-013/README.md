# ZX Spectrum Lesson 013 - Maze Runner

## Files

- `simple-maze.bas` - Basic collision detection with SCREEN$ function
- `maze-runner.bas` - Complete maze game with goal, move counter, and win condition

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

### simple-maze.bas
Basic collision detection demonstration:
- SCREEN$ function reads characters from screen
- Check destination before moving
- Walls drawn with CHR$ 127 (block graphics)
- Simple maze layout with vertical and horizontal walls
- QAOP keys for movement
- Player character represented by @ symbol

### maze-runner.bas
Complete maze game with multiple features:
- Complex maze with multiple rooms and passages
- Gaps in walls for navigation
- Goal marker (X) to find
- Move counter tracking player efficiency
- Win condition with victory screen
- Check-before-move pattern prevents walking through walls

## Key Concepts

- **SCREEN$(row,col)** - Returns character at screen position (collision detection)
- **Check-before-move** - Test destination before updating position
- **CHR$ 127** - Block graphics character for walls
- **Win conditions** - Detecting when player reaches goal
- **State tracking** - MOVES variable counts player actions
- **Subroutine organization** - 1000s for movement, 2000s for win condition
- **Complex maze design** - Multiple rooms, passages, and gaps

## Controls

### Both Programs
- Q - Move up
- A - Move down
- O - Move left
- P - Move right

### maze-runner.bas Only
- Reach the X to win
- Move counter displays efficiency

## Technical Details

- **SCREEN$ function**: Reads from display file memory, returns character at position
- **Collision detection**: Compare SCREEN$ result to " " (space) for walkable areas
- **NX, NY variables**: Calculate new position before checking/moving
- **GOSUB 1000**: Move player subroutine (only called if destination is valid)
- **GOSUB 2000**: Win condition handler (triggered when player reaches X)
- **CHR$ 127**: Outputs as █ (solid block) on Spectrum screen

## Maze Design

### Maze Layout (maze-runner.bas)
```
████████████████████████████████
█                              █
█        ██████████             █
█        █        █             █
█        █        █        █████
█        █        █        █
█        █ GAP    █        █  X
█        █        █        █
█        ██████████        █████
█                 GAP          █
█        ██████████            █
█                              █
████████████████████████████████
```

- Outer border (lines 50-120)
- Vertical walls (lines 140-170) with gap at Y=10
- Horizontal walls (lines 190-220) with gap at X=15
- Goal marker X placed at (10, 25)
- Player starts at (10, 5)

## Notes

- SCREEN$ uses same coordinates as PRINT AT (Y, X format)
- Checking destination prevents player from moving into walls
- Character at destination determines if move is valid
- Victory screen displays total moves taken
- PAUSE 0 waits for keypress before stopping program
- STOP command ends program (returns to BASIC prompt)
