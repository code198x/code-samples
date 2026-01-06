# Unit 5: The Crowd

Crowd meter system with game-over condition.

## What This Unit Covers

- Crowd meter as health/performance indicator
- Visual meter bar rendering with colour coding
- Game-over state when crowd meter depletes
- Hit/miss impact on crowd level
- Meter thresholds for colour changes

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Press **X** to hit notes. Hits fill the crowd meter; misses drain it. Game ends when the meter empties.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Health meter | crowd_level variable tracks performance |
| Bar rendering | Fill characters based on current level |
| Colour thresholds | Green → Yellow → Red as level drops |
| Game-over check | Test crowd_level for zero after miss |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
