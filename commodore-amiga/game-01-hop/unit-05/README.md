# Unit 5: Traffic Flow

Animated moving traffic on road lanes.

## What This Unit Covers

- Object position arrays
- Horizontal scrolling via position update
- Direction per lane
- Screen wrapping
- Frame-rate independent speed

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Cars move continuously across the road.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Object arrays | X position stored per car |
| Speed values | Pixels per frame movement |
| Lane direction | Alternate left/right per lane |
| Wrap around | Reset X when off-screen |

## Traffic Movement

```asm
move_traffic:
    lea     car_positions,a0
    move.w  car_count,d7
.loop:
    move.w  (a0),d0         ; Get X
    add.w   car_speed,d0    ; Add velocity
    cmp.w   #320,d0         ; Off right?
    blo.s   .nowrap
    sub.w   #320+32,d0      ; Wrap to left
.nowrap:
    move.w  d0,(a0)+
    dbf     d7,.loop
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
