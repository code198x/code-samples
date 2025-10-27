# ZX Spectrum Lesson 003 - Cave Explorer

## Files

- `cave-explorer.bas` - Complete text adventure game

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

A complete text adventure game where you explore a cave system, find treasure, and escape. Features:
- 4 rooms with descriptions
- Movement with N/S/E/W commands
- GET command to pick up treasure
- Win condition (escape with treasure)
- Lose condition (fall in pit)

## How to Play

Commands:
- **N** - Go north
- **S** - Go south
- **E** - Go east
- **W** - Go west
- **GET** - Pick up items
- **QUIT** - Exit game

Goal: Find the treasure in Room 3 and return to Room 1 (cave entrance) to win!

## Map

```
    [Room 2]
    Dark Passage
        |
    [Room 1]--[Room 4]
    Entrance    Pit!

    [Room 3]
    Treasure
```

## Notes

- Uses GOSUB/RETURN for room subroutines
- Variables track player position and inventory
- Simple but complete game loop
- Demonstrates state management in BASIC
