# Unit 1: Screen Setup

Basic display initialisation for the game.

## What This Unit Covers

- Clearing the screen
- Setting background and border colours
- Preparing for sprite graphics

## Key Concepts

| Concept | Description |
|---------|-------------|
| Screen memory | $0400-$07FF (default) |
| Colour RAM | $D800-$DBE7 |
| Border colour | $D020 |
| Background colour | $D021 |

## Expected Result

Black screen with dark blue border - the starfield backdrop ready for sprites.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
