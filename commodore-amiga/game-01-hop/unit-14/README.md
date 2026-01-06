# Unit 14: Level Progression

Difficulty scaling across levels.

## What This Unit Covers

- Level counter
- Speed increases
- Object density changes
- Level display
- Difficulty tables

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Each completed level increases difficulty.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Level variable | Increments on completion |
| Speed tables | Lookup for car/log speeds |
| Density | More objects at higher levels |
| Cap | Maximum difficulty level |

## Difficulty Scaling

| Level | Car Speed | Log Speed | Objects |
|-------|-----------|-----------|---------|
| 1 | 1 | 1 | 8 |
| 2 | 2 | 1 | 10 |
| 3 | 2 | 2 | 12 |
| 4 | 3 | 2 | 14 |
| 5+ | 3 | 3 | 16 |

## Level Setup

```asm
setup_level:
    move.w  level,d0
    cmp.w   #5,d0
    blo.s   .ok
    moveq   #5,d0           ; Cap at level 5
.ok:
    lea     speed_table,a0
    move.w  (a0,d0.w*2),car_speed
    lea     density_table,a0
    move.w  (a0,d0.w*2),num_cars
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
