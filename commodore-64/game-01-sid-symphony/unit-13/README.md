# Unit 13: Difficulty Progression

Dynamic speed based on multiplier level.

## What This Unit Covers

- Speed lookup table indexed by multiplier
- Move timer adjustment for difficulty
- Higher multiplier means faster notes
- Speed reset when multiplier drops
- Difficulty feedback loop

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Notes speed up as your multiplier increases, creating a natural difficulty curve.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Lookup table | Indexed array for speed values |
| Move timer | Lower value = faster note movement |
| Difficulty coupling | Multiplier drives both score and speed |
| Risk/reward | Higher scores require handling faster notes |

## Speed Table

| Multiplier | Move Timer | Effect |
|------------|------------|--------|
| 1x | 4 frames | Normal speed |
| 2x | 3 frames | Slightly faster |
| 3x | 2 frames | Fast |
| 4x | 2 frames | Maximum speed |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
