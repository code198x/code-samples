# Unit 9: Bullet Collision

Detect bullets hitting enemies.

## What This Unit Covers

- Bounding box collision detection
- Checking each bullet against enemy
- Hit response

## Key Concepts

| Concept | Description |
|---------|-------------|
| Bounding box | Rectangle overlap test |
| Hit zone | Enemy dimensions for collision |
| Iteration | Check all active bullets |
| Response | Deactivate bullet, damage enemy |

## Collision Detection

```asm
ENEMY_WIDTH  = 24
ENEMY_HEIGHT = 16

check_bullet_collisions:
    tst.b   enemy_active
    beq.s   .done

    lea     bullet_active,a0
    lea     bullet_x,a1
    lea     bullet_y,a2
    moveq   #MAX_BULLETS-1,d7

.check_bullet:
    tst.b   (a0)
    beq.s   .next

    ; Get bullet position
    move.w  (a1),d0             ; bullet X
    move.w  (a2),d1             ; bullet Y

    ; Check X overlap
    move.w  enemy_x,d2
    cmp.w   d2,d0
    blt.s   .next               ; Bullet left of enemy
    add.w   #ENEMY_WIDTH,d2
    cmp.w   d2,d0
    bgt.s   .next               ; Bullet right of enemy

    ; Check Y overlap
    move.w  enemy_y,d2
    cmp.w   d2,d1
    blt.s   .next               ; Bullet above
    add.w   #ENEMY_HEIGHT,d2
    cmp.w   d2,d1
    bgt.s   .next               ; Bullet below

    ; Hit!
    clr.b   (a0)                ; Deactivate bullet
    bsr     enemy_hit

.next:
    addq.l  #1,a0
    addq.l  #2,a1
    addq.l  #2,a2
    dbf     d7,.check_bullet

.done:
    rts
```

## Expected Result

Bullets that overlap with enemy trigger a hit response.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
