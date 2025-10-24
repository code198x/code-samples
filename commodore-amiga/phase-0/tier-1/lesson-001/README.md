# Commodore Amiga Lesson 001 - Hello, Amiga World

## Files

- `hello-amiga.amos` - Main example program demonstrating Screen Open, Curs Off, Cls, Ink, Centre, and Locate

## Running the Code

### On Real Hardware
1. Boot your Amiga into Workbench
2. Load AMOS Professional from disk
3. Type in the program or load the .amos file
4. Press F1 to run

### On Emulator (FS-UAE, WinUAE, etc.)
1. Start the emulator with AMOS Professional disk loaded
2. Boot AMOS Professional
3. Type in the program or load the .amos file
4. Press F1 to run

## What It Does

Opens a 320×256 pixel lowres screen with 16 colours, hides the cursor, clears to black, sets ink colour to 14 (yellow in default palette), and displays "HELLO, AMIGA!" centered at row 12.

## Expected Output

A black screen with yellow text "HELLO, AMIGA!" centered horizontally near the middle. Press any key to return to AMOS.

## Notes

- Screen 0 is the default screen
- Lowres mode is 320×256 pixels (PAL) with up to 32 colours
- Colour 14 is yellow in the default AMOS palette
- Centre calculates horizontal centering based on proportional font widths
