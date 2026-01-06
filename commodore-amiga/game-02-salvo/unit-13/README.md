# Unit 13: Wave System

Progressive enemy waves.

## What This Unit Covers

- Wave completion detection
- Wave counter
- Difficulty progression

## Key Concepts

| Concept | Description |
|---------|-------------|
| Wave clear | All enemies destroyed |
| Next wave | Reset enemies, increment counter |
| Difficulty | Faster enemies each wave |
| Wave display | Show current wave number |

## Wave Logic

```asm
wave_number:    dc.w    1
base_speed:     dc.w    2

check_wave_clear:
    lea     enemy_active,a0
    moveq   #MAX_ENEMIES-1,d7
    moveq   #0,d0               ; Count active

.count:
    tst.b   (a0)+
    beq.s   .next
    addq.w  #1,d0

.next:
    dbf     d7,.count

    tst.w   d0
    bne.s   .not_clear

    ; Wave cleared!
    bsr     next_wave

.not_clear:
    rts

next_wave:
    addq.w  #1,wave_number

    ; Increase difficulty
    move.w  base_speed,d0
    addq.w  #1,d0
    move.w  d0,base_speed

    ; Reset enemies
    bsr     init_enemies

    ; Display wave message
    bsr     show_wave_message
    rts
```

## Expected Result

Destroying all enemies starts next wave with faster movement.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
