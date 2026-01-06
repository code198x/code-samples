# Unit 2: First Sprite

Enable and display a hardware sprite.

## What This Unit Covers

- Enabling sprites via VIC-II
- Setting sprite position
- Setting sprite colour

## Key Concepts

| Concept | Description |
|---------|-------------|
| Sprite enable | $D015 - bit per sprite (0-7) |
| Sprite X position | $D000 + (sprite × 2) |
| Sprite Y position | $D001 + (sprite × 2) |
| Sprite colour | $D027 + sprite number |
| X high bit | $D010 - for X positions > 255 |

## Expected Result

A single sprite visible on screen (using default sprite data initially).

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
