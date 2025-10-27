# ZX Spectrum Lesson 002 - The Number Oracle

## Files

- `number-oracle.bas` - Interactive INPUT and IF/THEN demonstration
- `range-checker.bas` - Multiple IF conditions with AND logic

## Running the Code

### On Real Hardware
1. Switch on your ZX Spectrum
2. Wait for the "© 1982 Sinclair Research Ltd" message
3. Type in the program line by line
4. Type `RUN` and press ENTER

### On Emulator (Fuse, ZXSpin, etc.)
1. Start the emulator
2. Type in the program line by line
3. Type `RUN` and press ENTER

Alternatively, load the .bas file directly if your emulator supports it.

## What It Does

### number-oracle.bas
Asks for your name using INPUT with string variable (`n$`), then asks you to guess the number 7. Uses IF/THEN to check if your guess is correct and displays appropriate messages.

### range-checker.bas
Demonstrates multiple IF conditions and the AND operator. Checks if a number is within range (1-100) and tells you which half of the range it's in.

## Expected Output

### number-oracle.bas
Program prompts for name, greets you, then asks you to guess a number. Tells you if you guessed correctly (7) or not.

### range-checker.bas
Asks for a number, checks if it's in range (1-100), and if so, tells you whether it's in the lower half (1-49) or upper half (50-100).

## Notes

- String variables end with `$` (e.g. `n$`)
- IF/THEN executes command only if condition is true
- `<>` means "not equal to"
- AND combines multiple conditions (both must be true)
- PAUSE 0 waits for keypress before ending
