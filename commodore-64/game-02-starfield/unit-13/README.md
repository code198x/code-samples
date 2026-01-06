# Unit 13: Enemy Destruction

Handle bullet hitting enemy.

## What This Unit Covers

- Destroying enemy on hit
- Visual feedback (flash or explosion)
- Respawning enemy after delay

## Key Concepts

| Concept | Description |
|---------|-------------|
| Destroy enemy | Set inactive, hide sprite |
| Explosion effect | Change sprite colour briefly |
| Respawn timer | Frames until new enemy appears |
| Bullet consumed | Deactivate bullet on hit |

## Destruction Logic

```asm
handle_hit:
    ; Deactivate bullet
    lda #0
    sta bullet_active

    ; Flash enemy colour
    lda #1              ; White
    sta $D02B           ; Sprite 5 colour

    ; Set respawn timer
    lda #60             ; 1 second at 60fps
    sta respawn_timer

    ; Hide enemy
    lda $D015
    and #%11011111      ; Clear bit 5
    sta $D015
    rts
```

## Expected Result

Enemy disappears when hit by bullet, reappears after delay.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
