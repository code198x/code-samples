# Unit 10: Home Zone

Goal slots and level completion.

## What This Unit Covers

- Home slot positions
- Slot occupancy tracking
- Goal detection
- Level completion logic
- Bonus scoring

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Reach the home slots at the top to score. Fill all slots to complete level.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Home slots | 5 goal positions at top |
| Slot flags | Track which slots filled |
| Goal detection | Frog Y position + X alignment |
| Level complete | All 5 slots filled |

## Home Zone Logic

```asm
check_home:
    cmp.w   #HOME_Y,frog_y
    bne.s   .not_home
    ; Check which slot
    move.w  frog_x,d0
    sub.w   #HOME_LEFT,d0
    divu.w  #HOME_SPACING,d0
    cmp.w   #5,d0
    bge.s   .miss
    ; Check if slot empty
    lea     home_slots,a0
    tst.b   (a0,d0.w)
    bne.s   .occupied
    ; Fill slot
    move.b  #1,(a0,d0.w)
    jsr     add_bonus
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
