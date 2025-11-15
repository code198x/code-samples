# Lesson 031: Visual Polish

Add visual flourishes: score flash on point, center line.

## Concepts Demonstrated

- **Palette animation**: Flash score colors for 30 frames
- **Center line**: Vertical dashed line using sprites
- **Timer-based effects**: Decrement flash_timer each frame
- **Visual feedback**: Immediate response to scoring

## Polish Elements

```
Score flash:  Palette swap $3F01 for 30 frames
Center line:  8 sprites (Y=32,64,96,128,160,192,224), tile $02
Flash timer:  30 frames = 0.5 seconds at 60fps
```

## Building

```bash
ca65 visual-polish.asm -o visual-polish.o
ld65 visual-polish.o -C ../lesson-001/nes.cfg -o visual-polish.nes
```

## Testing

Score changes → score flashes bright white for 0.5 seconds
Center line visible throughout game

## What Changed from Lesson 030

1. Added `flash_timer` variable
2. `UpdateFlash` decrements timer
3. `DrawCenterLine` places 8 vertical sprites
4. Palette flash on score in NMI
5. Center line tile ($02) in CHR-ROM
