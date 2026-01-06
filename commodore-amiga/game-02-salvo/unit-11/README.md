# Unit 11: Multiple Enemies

Expand to multiple enemy sprites.

## What This Unit Covers

- Enemy array data structure
- Processing multiple enemies
- Independent movement patterns

## Key Concepts

| Concept | Description |
|---------|-------------|
| Enemy count | 3-4 enemies (sprite/BOB limit) |
| Array structure | Parallel arrays for state |
| Individual patterns | Different starting positions/directions |
| Collision update | Check bullets against all enemies |

## Enemy Arrays

```asm
MAX_ENEMIES = 4

enemy_active:   dcb.b   MAX_ENEMIES,1
enemy_x:        dc.w    60,120,180,240
enemy_y:        dc.w    50,50,50,50
enemy_dir:      dc.w    2,-2,2,-2
enemy_dying:    dcb.b   MAX_ENEMIES,0
```

## Update All Enemies

```asm
update_enemies:
    lea     enemy_active,a0
    lea     enemy_x,a1
    lea     enemy_dir,a2
    moveq   #MAX_ENEMIES-1,d7

.loop:
    tst.b   (a0)
    beq.s   .next

    ; Update position
    move.w  (a1),d0
    add.w   (a2),d0

    ; Boundary check
    cmp.w   #32,d0
    blt.s   .reverse
    cmp.w   #288,d0
    bgt.s   .reverse
    bra.s   .store

.reverse:
    neg.w   (a2)
    move.w  (a1),d0
    add.w   (a2),d0

.store:
    move.w  d0,(a1)

.next:
    addq.l  #1,a0
    addq.l  #2,a1
    addq.l  #2,a2
    dbf     d7,.loop
    rts
```

## Expected Result

Multiple enemies moving independently across the screen.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
