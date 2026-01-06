# Unit 3: Hit or Miss

Hit detection logic with visual feedback.

## What This Unit Covers

- Hit zone collision detection
- Key-down transition detection (edge triggering)
- Colour-based visual feedback (green=hit, red=miss)
- Flash timer management
- Miss detection when notes scroll off-screen

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Press **X** when notes enter the hit zone (left side of track). The hit zone flashes green for hits, red for misses.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Edge detection | Compare current vs previous key state |
| Hit zone | Notes with X position < HIT_ZONE_W are hittable |
| Flash timers | Count down each frame, restore colour when zero |
| Priority logic | Hit flash takes priority over miss flash |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
