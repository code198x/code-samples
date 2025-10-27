# ZX Spectrum Lesson 004 - Brain Challenge

## Files

- `brain-challenge.bas` - Complete quiz game with scoring
- `data-demo.bas` - Simple demonstration of READ/DATA

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

### brain-challenge.bas
A complete quiz game featuring:
- 5 questions stored in DATA statements
- Score tracking
- Correct/wrong feedback
- Final score with performance message
- READ command to retrieve questions and answers

### data-demo.bas
A simple high scores table demonstrating:
- Reading multiple data types (strings and numbers)
- FOR loop with READ
- TAB for column alignment
- Displaying structured data

## Key Concepts

- **DATA** - Store lists of values in your program
- **READ** - Retrieve values from DATA statements in order
- **Mixed types** - DATA can hold both strings and numbers
- **Sequential access** - READ moves through DATA one value at a time

## Notes

- READ gets values from DATA in the order they appear
- Once all DATA is read, program gives "Out of DATA" error
- Use a counter to know when to stop reading
- Strings in DATA don't need quotes unless they contain commas
