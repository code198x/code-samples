# Unit 8: Bullet Movement

Animate the bullet travelling upward.

## What This Unit Covers

- Updating bullet position each frame
- Deactivating bullet when off-screen
- Bullet speed control

## Key Concepts

| Concept | Description |
|---------|-------------|
| Bullet speed | Pixels per frame (4-6 typical) |
| Off-screen check | Y position < top boundary |
| Deactivation | Set active flag to 0, hide sprite |

## Movement Logic

```asm
update_bullet:
    lda bullet_active
    beq done            ; Skip if inactive

    lda bullet_y
    sec
    sbc #4              ; Move up 4 pixels
    sta bullet_y

    cmp #30             ; Off top of screen?
    bcs update_sprite
    lda #0
    sta bullet_active   ; Deactivate

update_sprite:
    lda bullet_y
    sta $D003           ; Sprite 1 Y position
done:
```

## Expected Result

Bullet travels upward from player ship and disappears at top of screen.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
