    ; --- Tile collision ---
    lda vel_y
    bmi @no_floor           ; Moving upward — skip floor check

    ; Calculate tile row (feet position)
    lda player_y
    clc
    adc #8                  ; Bottom of sprite
    lsr
    lsr
    lsr                     ; / 8 = tile row
    tax

    ; Bounds check: below screen = solid
    cpx #30
    bcs @on_solid

    ; Load row pointer from level data
    lda level_rows_lo, x
    sta tile_ptr
    lda level_rows_hi, x
    sta tile_ptr+1

    ; Calculate tile column (sprite centre)
    lda player_x
    clc
    adc #4                  ; Centre of 8-pixel sprite
    lsr
    lsr
    lsr                     ; / 8 = tile column
    tay

    ; Read tile at (row, col)
    lda (tile_ptr), y       ; Indirect indexed addressing
    beq @no_floor           ; Tile 0 = empty

@on_solid:
    ; Snap player to tile surface
    lda player_y
    clc
    adc #8                  ; Feet Y
    and #%11111000          ; Round down to tile boundary
    sec
    sbc #8                  ; Back to sprite top
    sta player_y
    lda #0
    sta vel_y
    lda #1
    sta on_ground
    jmp @done_floor

@no_floor:
    lda #0
    sta on_ground

@done_floor:
