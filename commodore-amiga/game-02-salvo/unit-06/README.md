# Unit 6: Bullet Pooling

Support multiple bullets in flight.

## What This Unit Covers

- Bullet pool data structure
- Iterating through active bullets
- Using multiple sprites or BOBs

## Key Concepts

| Concept | Description |
|---------|-------------|
| Pool size | 4 bullets (sprites 1-4) |
| Pool arrays | active, x, y for each bullet |
| Free slot search | Find inactive bullet |
| Update loop | Process all active bullets |

## Pool Structure

```asm
MAX_BULLETS = 4

bullet_active:  dcb.b   MAX_BULLETS,0
bullet_x:       dcb.w   MAX_BULLETS,0
bullet_y:       dcb.w   MAX_BULLETS,0
```

## Spawn Logic

```asm
spawn_bullet:
    lea     bullet_active,a0
    moveq   #MAX_BULLETS-1,d7

.find_slot:
    tst.b   (a0)+
    beq.s   .found
    dbf     d7,.find_slot
    rts                         ; No free slots

.found:
    subq.l  #1,a0               ; Back to empty slot
    move.b  #1,(a0)

    ; Calculate index and set position
    ; ...
    rts
```

## Update All Bullets

```asm
update_bullets:
    lea     bullet_active,a0
    lea     bullet_y,a1
    moveq   #MAX_BULLETS-1,d7

.loop:
    tst.b   (a0)+
    beq.s   .next
    ; Update this bullet's Y
    ; Check off-screen

.next:
    addq.l  #2,a1               ; Next Y entry
    dbf     d7,.loop
    rts
```

## Expected Result

Player can fire up to 4 bullets simultaneously.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
