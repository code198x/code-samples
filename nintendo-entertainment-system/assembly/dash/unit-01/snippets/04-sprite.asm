    ; Set up player sprite in OAM buffer
    lda #PLAYER_Y
    sta oam_buffer+0        ; Y position
    lda #PLAYER_TILE
    sta oam_buffer+1        ; Tile number
    lda #0
    sta oam_buffer+2        ; Attributes (palette 0, no flip)
    lda #PLAYER_X
    sta oam_buffer+3        ; X position

    ; Hide all other sprites (Y = $EF moves off visible screen)
    lda #$EF
    ldx #4
@hide_sprites:
    sta oam_buffer, x
    inx
    bne @hide_sprites
