# Unit 8: Collision and Death

Hit detection, death animation, and respawn.

## What This Unit Covers

- Car collision detection
- Water death detection
- Death animation sequence
- Respawn to start position
- Lives decrement

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Hitting a car or falling in water triggers death.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Bounding box | Rectangle overlap test |
| Death flag | State variable triggers animation |
| Animation frames | Cycle through death sprites |
| Respawn | Reset position after animation |

## Collision Detection

```asm
check_car_hit:
    lea     car_positions,a0
    move.w  car_count,d7
.loop:
    ; Check X overlap
    move.w  (a0)+,d0
    sub.w   frog_x,d0
    bpl.s   .positive
    neg.w   d0
.positive:
    cmp.w   #16,d0          ; Width overlap?
    bge.s   .next
    ; Check Y overlap (same lane)
    ...
    bra     death
.next:
    dbf     d7,.loop
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
