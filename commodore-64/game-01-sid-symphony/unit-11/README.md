# Unit 11: Combo System

Combo multiplier with consecutive hit tracking.

## What This Unit Covers

- Combo counter incremented on hits
- Multiplier tiers based on combo count
- Score multiplication without MUL instruction
- Multiplier display on screen
- Miss resets both combo and multiplier

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Build combos for higher multipliers. Miss any note and multiplier resets to 1x.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Combo counter | Tracks consecutive successful hits |
| Multiplier tiers | Every 10 hits increases multiplier |
| Shift multiplication | ASL to multiply by 2, add for 3x/4x |
| State coupling | Multiplier affects both score and difficulty |

## Multiplier Tiers

| Combo Hits | Multiplier |
|------------|------------|
| 0-9 | 1x |
| 10-19 | 2x |
| 20-29 | 3x |
| 30+ | 4x |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
