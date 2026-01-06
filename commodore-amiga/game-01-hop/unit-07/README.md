# Unit 7: Riding the Logs

Platform riding mechanics for river traversal.

## What This Unit Covers

- Frog-log collision detection
- Automatic horizontal movement
- Log carrying frog with current
- Edge-of-screen death

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Jump onto logs to cross the river; the frog rides along.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Platform detection | Check if frog overlaps log |
| Carry velocity | Frog moves with log |
| River zone | Y range for log riding |
| Screen edge | Death if carried off-screen |

## Platform Logic

```asm
check_on_log:
    ; Is frog in river zone?
    cmp.w   #RIVER_TOP,frog_y
    blt.s   .not_river
    cmp.w   #RIVER_BOTTOM,frog_y
    bge.s   .not_river
    ; Check each log for overlap
    jsr     find_log_under_frog
    tst.w   d0
    beq.s   .in_water       ; No log = death
    ; Apply log velocity to frog
    add.w   log_velocity,frog_x
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
