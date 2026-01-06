# Unit 12: Enemy-Player Collision

Handle enemies hitting the player.

## What This Unit Covers

- Player-enemy collision detection
- Invulnerability period
- Damage feedback

## Key Concepts

| Concept | Description |
|---------|-------------|
| Collision check | Enemy overlaps player |
| Invulnerability | Brief period after hit |
| Lives | Decrement on collision |
| Flash effect | Visual feedback |

## Player Collision

```asm
PLAYER_WIDTH  = 24
PLAYER_HEIGHT = 16

check_player_collision:
    tst.b   player_invuln
    bne.s   .done               ; Already invulnerable

    lea     enemy_active,a0
    lea     enemy_x,a1
    lea     enemy_y,a2
    moveq   #MAX_ENEMIES-1,d7

.check_enemy:
    tst.b   (a0)
    beq.s   .next

    ; Bounding box check
    move.w  (a1),d0             ; enemy X
    move.w  player_x,d2
    sub.w   #PLAYER_WIDTH,d2
    cmp.w   d2,d0
    blt.s   .next
    add.w   #PLAYER_WIDTH*2,d2
    cmp.w   d2,d0
    bgt.s   .next

    ; Y check similar...

    ; Hit!
    bsr     player_hit
    bra.s   .done

.next:
    addq.l  #1,a0
    addq.l  #2,a1
    addq.l  #2,a2
    dbf     d7,.check_enemy

.done:
    rts

player_hit:
    subq.b  #1,lives
    move.b  #120,player_invuln  ; 2 second invulnerability
    rts
```

## Expected Result

Player loses a life when touching an enemy. Brief invulnerability follows.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
