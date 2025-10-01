# Commodore 64 BASIC - Code Samples

Complete code samples for the C64 BASIC course.

## How to Use These Files

BASIC programs are provided as `.bas` text files. You have three options:

### Option 1: Type It In (Classic Experience!)

The authentic retro way:

1. Start VICE emulator (`x64sc`)
2. Type `NEW` to clear memory
3. Type each line from the `.bas` file
4. Type `RUN` to execute

This is how it was done in the 1980s! Great for learning.

### Option 2: Copy-Paste (Modern Convenience)

If your emulator setup supports it:

1. Open the `.bas` file in a text editor
2. Copy all the lines
3. Paste into the VICE emulator window
4. Type `RUN`

**Note**: This may require configuring VICE to accept pasted input.

### Option 3: Convert to PRG (Direct Loading)

Use `petcat` to convert text to a loadable `.prg` file:

```bash
# Convert .bas to .prg
petcat -w2 -o number-hunter.prg -- number-hunter.bas

# Load in VICE
x64sc number-hunter.prg
```

The `-w2` flag means "BASIC V2" (C64 BASIC version).

**Installing petcat:**
- Linux: `sudo apt-get install vice`
- macOS: `brew install vice`
- Windows: Included with VICE installation

## Week 1 Content

### Lessons 1-2
These lessons use immediate mode (no line numbers) - no files needed, just type the commands directly!

### Lesson 3-7
These lessons build up concepts piece by piece with small example programs shown in the lesson text. No complete "game" files needed - follow along in the lessons.

### Lesson 8: Number Hunter
**Complete game**: `lesson-08/number-hunter.bas`

A number guessing game featuring:
- Random number generation
- Input validation
- Score tracking
- Color-coded feedback
- Replay functionality

## Saving Your Work

Once you've typed in or loaded a program, save it to a virtual disk:

```basic
SAVE "PROGRAM NAME",8
```

The `,8` means "save to disk drive 8" (the default in VICE).

To load it later:

```basic
LOAD "PROGRAM NAME",8
RUN
```

## Program Structure

C64 BASIC programs use **line numbers** (10, 20, 30...):
- Lines execute in numerical order
- `GOTO` jumps to specific line numbers
- `REM` adds comments
- Programs persist in memory until `NEW` or power off

## Common Commands

```basic
NEW          Clear memory (start fresh)
LIST         Show current program
RUN          Execute program
STOP         Halt running program (or RUN/STOP key)
SAVE "NAME",8   Save to disk
LOAD "NAME",8   Load from disk
```

## Troubleshooting

**?SYNTAX ERROR**
- Check for typos in commands
- Make sure quotes are matched
- Verify line numbers are correct

**?UNDEF'D STATEMENT ERROR**
- A GOTO refers to a non-existent line number
- Check your GOTOs match actual line numbers

**Program won't stop running**
- Press RUN/STOP key on keyboard
- Or use Cmd+H in VICE (macOS) / Alt+H (Linux/Windows)

## Next Steps

After Week 1, you'll learn:
- Disk operations and file management
- Advanced variables and arrays
- Sprites and graphics
- Sound and music
- Reading joystick input

## Resources

- [VICE Emulator](https://vice-emu.sourceforge.io/)
- [C64 BASIC Manual](https://www.c64-wiki.com/wiki/BASIC)
- Main course website: https://code198x.stevehill.xyz
