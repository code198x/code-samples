# ZX Spectrum Lesson 014 - Collect and Score

## Files

- `simple-collect.bas` - Basic item collection with score tracking
- `treasure-hunt.bas` - Complete collection game with maze, scoring, and efficiency rating

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

### simple-collect.bas
Basic collection mechanics:
- Five stars (*) placed around screen
- Player moves with QAOP to collect them
- SCORE variable tracks collected items
- Win condition when all items collected
- Sound effect (BEEP) on collection
- Victory message with BRIGHT colours
- No maze walls - open playfield

### treasure-hunt.bas
Complete treasure hunting game:
- Complex maze with multiple rooms and passages
- Eight gold pieces ($) to collect
- Move counter tracks total steps taken
- Efficiency rating based on moves per treasure
- Different messages for excellent/good/try again performance
- Sound effects on collection
- Victory fanfare (multiple BEEPs)
- Cyan colour scheme for treasures

## Key Concepts

- **Score tracking** - SCORE variable increments on collection
- **Item counting** - ITEMS variable stores total collectibles
- **Win detection** - IF SCORE=ITEMS triggers victory
- **Collection subroutine** - Separate GOSUB for item pickup logic
- **Score display** - PRINT AT updates fixed position
- **Clearing display** - Print spaces before updating numbers
- **Efficiency rating** - Dividing MOVES by ITEMS for performance metric
- **Conditional messages** - Different feedback based on performance

## Controls

### Both Programs
- Q - Move up
- A - Move down
- O - Move left
- P - Move right
- Collect all items to win

## Technical Details

- **SCREEN$ detection**: Check for "$" or "*" characters at destination
- **Collection pattern**: Erase player → Move to item position → Increment score → Redraw player
- **Score display**: Print spaces to clear old digits, then print new score
- **WIN condition**: Checked after every collection (not every move)
- **BEEP timing**: 0.05 duration for quick collection sound, 0.3-0.5 for victory
- **INT function**: Converts MOVES/ITEMS to integer for efficiency rating
- **BRIGHT 1**: Makes victory text stand out

## Game Flow

### simple-collect.bas
1. Place 5 stars on screen
2. Initialize SCORE=0, ITEMS=5
3. Game loop: read input, check destination
4. If destination is star → collect (GOSUB 1000)
5. If destination is space → move (GOSUB 2000)
6. After collection, check if SCORE=ITEMS
7. If all collected → victory screen (GOSUB 3000)

### treasure-hunt.bas
1. Draw complex maze with walls and gaps
2. Place 8 gold pieces in different rooms
3. Initialize SCORE=0, ITEMS=8, MOVES=0
4. Game loop: read input, check destination
5. Collection increments both SCORE and MOVES
6. Movement increments MOVES only
7. When SCORE=ITEMS → calculate efficiency
8. Display rating based on efficiency:
   - <10 moves per treasure = EXCELLENT
   - 10-14 moves per treasure = GOOD
   - >=15 moves per treasure = TRY AGAIN

## Subroutine Organization

- **1000s**: Collection logic (item pickup)
- **2000s**: Movement logic (empty space)
- **3000s**: Win conditions and endings

## Notes

- Collection removes item from screen (player moves into that position)
- Score display uses spaces to clear previous digits
- MOVES counter tracks navigation efficiency
- Efficiency rating adds replayability (compete for better score)
- BEEP frequencies: higher numbers (10-15) = higher pitch
- Victory fanfare: ascending notes (0, 5, 10, 15)
- CHR$ 127 blocks prevent passing through walls
- Eight treasures create multiple collection paths
- Gaps in walls are critical for maze solvability
