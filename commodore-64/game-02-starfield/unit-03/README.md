# Unit 3: Sprite Graphics

Define custom sprite data for the player ship.

## What This Unit Covers

- Sprite data format (24×21 pixels, 63 bytes)
- Sprite pointers in screen memory
- Memory alignment for sprite data

## Key Concepts

| Concept | Description |
|---------|-------------|
| Sprite data | 63 bytes: 3 bytes × 21 rows |
| Sprite pointer | Screen memory + $03F8 + sprite number |
| Pointer value | Block number (address ÷ 64) |
| Alignment | Sprite data must be 64-byte aligned |

## Ship Design

```
....##....##....
...####..####...
...############...
..##############..
..##############..
.################.
.######....######.
.######....######.
```

## Expected Result

Player ship sprite displayed using custom graphics data.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
