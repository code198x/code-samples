# Unit 9: Walk Animation

Animate the player while walking.

## What This Unit Covers

- Animation frame counter
- Cycling through frames
- Direction facing

## Key Concepts

| Concept | Description |
|---------|-------------|
| Frame counter | Cycles through animation frames |
| Animation speed | Frames per animation step |
| Tile indices | Different tiles for each frame |
| Flip attribute | Mirror sprite for left/right |

## Animation Variables

```asm
anim_frame:     .res 1      ; Current frame (0-3)
anim_timer:     .res 1      ; Countdown to next frame
facing_left:    .res 1      ; Direction flag

ANIM_SPEED = 8              ; Frames per animation step
```

## Walk Animation

```asm
walk_frames:
    .byte $00, $02, $04, $02    ; Tile indices for 4-frame walk

update_walk_anim:
    ; Only animate if moving
    lda buttons
    and #(BUTTON_LEFT | BUTTON_RIGHT)
    beq @idle

    ; Update timer
    dec anim_timer
    bne @done

    ; Next frame
    lda #ANIM_SPEED
    sta anim_timer

    inc anim_frame
    lda anim_frame
    and #$03                ; Wrap at 4
    sta anim_frame
    bra @done

@idle:
    ; Reset to standing frame
    lda #0
    sta anim_frame

@done:
    rts
```

## Sprite Update

```asm
update_player_tiles:
    ldx anim_frame
    lda walk_frames,x
    sta OAM+1               ; Top-left tile
    clc
    adc #1
    sta OAM+5               ; Top-right tile
    ; ... bottom tiles

    ; Set flip attribute if facing left
    lda facing_left
    beq @no_flip
    lda #%01000000          ; Horizontal flip
    bra @set_attr
@no_flip:
    lda #$00
@set_attr:
    sta OAM+2
    sta OAM+6
    ; ...
    rts
```

## Expected Result

Player animates while walking. Faces direction of movement.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
