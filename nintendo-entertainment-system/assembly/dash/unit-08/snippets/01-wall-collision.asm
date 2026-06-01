    ; --- Move left (with wall check) ---
    lda buttons
    and #BTN_LEFT
    beq @not_left
    lda player_x
    beq @not_left

    ; Check tile to the left of player
    lda player_y
    clc
    adc #4                  ; Vertical centre of sprite
    lsr
    lsr
    lsr                     ; / 8 = tile row
    tax

    lda level_rows_lo, x
    sta tile_ptr
    lda level_rows_hi, x
    sta tile_ptr+1

    lda player_x
    sec
    sbc #1                  ; One pixel left of current position
    lsr
    lsr
    lsr                     ; / 8 = tile column
    tay

    lda (tile_ptr), y
    bne @not_left           ; Solid tile — blocked

    dec player_x
@not_left:

    ; --- Move right (with wall check) ---
    lda buttons
    and #BTN_RIGHT
    beq @not_right
    lda player_x
    cmp #RIGHT_WALL
    bcs @not_right

    ; Check tile to the right of player
    lda player_y
    clc
    adc #4                  ; Vertical centre of sprite
    lsr
    lsr
    lsr                     ; / 8 = tile row
    tax

    lda level_rows_lo, x
    sta tile_ptr
    lda level_rows_hi, x
    sta tile_ptr+1

    lda player_x
    clc
    adc #8                  ; Right edge of sprite
    lsr
    lsr
    lsr                     ; / 8 = tile column
    tay

    lda (tile_ptr), y
    bne @not_right          ; Solid tile — blocked

    inc player_x
@not_right:
