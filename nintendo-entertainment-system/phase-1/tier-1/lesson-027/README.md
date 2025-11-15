# Lesson 027: Score Display

Display scores using nametable updates during VBlank.

## Concepts Demonstrated

- **Nametable updates**: Write tiles during VBlank
- **PPU addressing**: $2006/$2007 for VRAM writes
- **Score positioning**: Top center of screen
- **Frame timing**: Updates during NMI only

## Nametable Layout

```
Nametable address $2000 (top-left screen):
Row 2, Column 10: Player 1 score (2 digits)
Row 2, Column 20: Player 2 score (2 digits)
```

## Building

```bash
ca65 score-display.asm -o score-display.o
ld65 score-display.o -C ../lesson-001/nes.cfg -o score-display.nes
```

## Testing

Scores now visible on screen! Let ball pass paddle to see scores increment.

## What Changed from Lesson 026

1. `UpdateScoreDisplay` function writes to nametable
2. Called during NMI (VBlank)
3. PPU address set to score positions
4. Digit tiles written via $2007
