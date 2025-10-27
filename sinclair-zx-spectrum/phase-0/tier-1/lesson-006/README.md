# ZX Spectrum Lesson 006 - Fact Finder

## Files

- `array-demo.bas` - Simple array demonstration with high scores
- `fact-finder.bas` - Complete knowledge database system with search and quiz

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

### array-demo.bas
Simple demonstration of arrays:
- DIM to create arrays
- Loading arrays from DATA
- Displaying array contents in a formatted table
- Mixing string arrays (NAME$) with numeric arrays (SCORE)

### fact-finder.bas
A complete knowledge database system featuring:
- Dynamic loading of facts from DATA into arrays
- Menu system with three modes:
  1. Browse all facts
  2. Search by keyword using INSTR
  3. Random quiz using RND to select questions
- Uses sentinel value ("END") to detect end of DATA
- COUNT variable tracks number of facts loaded

## Key Concepts

- **DIM** - Declare arrays before use
- **Array indexing** - Access elements with Q$(1), Q$(2), etc.
- **Loading arrays** - Read DATA into array slots
- **Sentinel values** - Use special value to mark end of DATA
- **Search** - Loop through array comparing values
- **INSTR** - Find substring within string
- **RND** - Random number generation for quiz

## Program Structure

```
30-130:    Data loading (build arrays from DATA)
200-350:   Main menu loop
1000-1999: Browse mode
2000-2999: Search mode
3000-3999: Quiz mode
9000+:     DATA statements
```

## Notes

- Arrays must be DIM'd before use
- Indices start at 1 by default
- INSTR returns 0 if substring not found, >0 if found
- RND generates 0-0.999..., multiply and add 1 for 1-COUNT range
- Sentinel pattern avoids hardcoding data count
- Search is case-sensitive (LONDON vs London)
