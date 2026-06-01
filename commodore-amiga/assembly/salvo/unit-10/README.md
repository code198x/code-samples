# Unit 10: Enemy Destruction

Visual feedback when enemies are hit.

## What This Unit Covers

- Destruction animation
- Respawn timer
- Explosion effect using copper

## Key Concepts

| Concept | Description |
|---------|-------------|
| Flash effect | Change sprite colours briefly |
| Explosion | Alternate sprite or colour cycle |
| Respawn delay | Frames until enemy returns |
| State | Dying vs active vs inactive |

## Enemy Hit Handler

```asm
enemy_hit:
    ; Start destruction sequence
    move.b  #1,enemy_dying
    move.w  #15,explosion_timer ; 15 frames

    ; Flash colour
    move.w  #$0FFF,COLOR21      ; White flash
    rts

update_explosion:
    tst.b   enemy_dying
    beq.s   .done

    subq.w  #1,explosion_timer
    bgt.s   .continue

    ; Explosion finished
    clr.b   enemy_dying
    clr.b   enemy_active

    ; Set respawn timer
    move.w  #120,respawn_timer  ; 2 seconds

    bra.s   .done

.continue:
    ; Cycle explosion colours
    move.w  explosion_timer,d0
    and.w   #3,d0
    lsl.w   #4,d0
    or.w    #$0F00,d0
    move.w  d0,COLOR21

.done:
    rts
```

## Expected Result

Enemy flashes and disappears when hit. Reappears after delay.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
