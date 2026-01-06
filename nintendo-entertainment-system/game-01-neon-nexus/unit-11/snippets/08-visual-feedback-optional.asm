; Example: flash background red at max difficulty
update_palette:
    lda difficulty
    cmp #MAX_DIFFICULTY
    bne @normal

    ; At max difficulty, cycle background
    lda frame_counter
    and #%00010000          ; toggle every 16 frames
    beq @normal

    ; Set danger palette
    ; (would require PPU palette update)

@normal:
    rts
