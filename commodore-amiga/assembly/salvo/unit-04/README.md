# Unit 4: Bullet Sprite

Add bullet with fire button.

## What This Unit Covers

- Second hardware sprite for bullet
- Fire button detection
- Spawning bullet at player position

## Key Concepts

| Concept | Description |
|---------|-------------|
| Sprite 1 | Used for bullet |
| Fire button | CIAA port A, active low |
| Spawn | Copy player position to bullet |
| Active flag | Track if bullet in flight |

## Fire Button

```asm
CIAA_PRA = $BFE001

check_fire:
    btst    #7,CIAA_PRA         ; Fire button (active low)
    bne.s   .not_pressed

    tst.b   bullet_active
    bne.s   .not_pressed        ; Already firing

    ; Spawn bullet
    move.b  #1,bullet_active
    move.w  player_x,bullet_x
    move.w  player_y,bullet_y
    subq.w  #8,bullet_y         ; Start above player

.not_pressed:
    rts
```

## Bullet Sprite

```asm
bullet_sprite:
    dc.w    $0000,$0000         ; Position (updated dynamically)
    dc.w    %0000000110000000
    dc.w    %0000000000000000
    dc.w    %0000000110000000
    dc.w    %0000000000000000
    dc.w    0,0                 ; End
```

## Expected Result

Pressing fire spawns a bullet at the player's position.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
