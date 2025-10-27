# ZX Spectrum Lesson 005 - Quiz Master

## Files

- `restore-demo.bas` - Simple demonstration of RESTORE command
- `quiz-master.bas` - Complete quiz game with categories and high scores

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

### restore-demo.bas
Demonstrates RESTORE functionality:
- Reads through DATA once
- Uses RESTORE to reset the READ pointer
- Reads through the same DATA again
- Shows that RESTORE allows DATA reuse

### quiz-master.bas
A complete quiz system featuring:
- Three quiz categories (Animals, Geography, Science)
- Menu system for category selection
- High score tracking across multiple games
- Structured program organization
- RESTORE used to access different DATA sections
- Reusable quiz engine (subroutine 5000)

## Key Concepts

- **RESTORE** - Resets READ pointer to the start of DATA
- **RESTORE linenumber** - Jump to specific DATA line
- **Menu systems** - Present choices and branch to subroutines
- **High score tracking** - Compare and update best score
- **Structured programs** - Logical line number ranges

## Program Structure

```
40-180:    Main menu loop
1000-3999: Category subroutines
5000-5999: Shared quiz engine
9000+:     DATA statements (organized by category)
```

## Notes

- RESTORE with no line number resets to first DATA statement
- RESTORE 9000 jumps to specific DATA line
- High score persists until program stops
- Each category uses same quiz engine (subroutine 5000)
- Menu returns after each quiz completes
