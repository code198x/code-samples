# Unit 7: Bullet Sprite

Add a second sprite for the player's bullet.

## What This Unit Covers

- Enabling multiple sprites
- Separate sprite data for bullet
- Fire button detection

## Key Concepts

| Concept | Description |
|---------|-------------|
| Sprite 1 | Player ship |
| Sprite 2 | Bullet |
| Fire detection | Check bit 4 of $DC00 |
| Bullet state | Active/inactive flag |

## Bullet Design

Small vertical projectile:

```
..##..
..##..
..##..
..##..
```

## Fire Logic

```asm
check_fire:
    lda $DC00
    and #%00010000      ; Fire button (bit 4)
    bne not_firing      ; 1 = not pressed
    lda bullet_active
    bne not_firing      ; Already active
    jsr spawn_bullet
not_firing:
```

## Expected Result

Pressing fire spawns a bullet at the player's position.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
