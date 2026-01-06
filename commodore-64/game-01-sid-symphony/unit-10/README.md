# Unit 10: Timing Grades

Perfect/Good/Late grades with different point values.

## What This Unit Covers

- Timing window calculation based on note position
- Grade assignment (Perfect, Good, Late)
- Variable point awards per grade
- On-screen grade text display
- Colour-coded feedback per grade

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Hit timing now matters: earlier hits in the zone score higher.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Timing windows | Note X position determines grade |
| Grade thresholds | Configurable boundaries between grades |
| Variable scoring | Points multiplied by grade quality |
| Text feedback | Show "PERFECT", "GOOD", or "LATE" on hit |

## Timing Windows

| Grade | Position | Points | Colour |
|-------|----------|--------|--------|
| Perfect | 0-2 | 15 | Green |
| Good | 3-5 | 10 | Yellow |
| Late | 6-7 | 5 | Red |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
