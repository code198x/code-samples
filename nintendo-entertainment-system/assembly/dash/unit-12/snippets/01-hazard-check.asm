; =============================================================================
; Hazard tile check
; =============================================================================
; After the floor collision code sets on_ground, this section reads the tile
; beneath the player's feet. If it's a spike, the player resets to start.
; =============================================================================

    ; --- Check for hazard tiles ---
    lda on_ground
    beq @no_hazard

    ; Get tile below player's feet
    lda player_y
    clc
    adc #8                  ; Feet position
    lsr
    lsr
    lsr                     ; Tile row
    tax

    cpx #30
    bcs @no_hazard          ; Below nametable — safe

    lda level_rows_lo, x
    sta tile_ptr
    lda level_rows_hi, x
    sta tile_ptr+1

    lda player_x
    clc
    adc #4                  ; Sprite centre
    lsr
    lsr
    lsr                     ; Tile column
    tay

    lda (tile_ptr), y
    cmp #SPIKE_TILE
    bne @no_hazard

    ; Hit spikes! Reset player to start
    lda #PLAYER_X
    sta player_x
    lda #PLAYER_Y
    sta player_y
    lda #0
    sta vel_y
    lda #1
    sta on_ground

    ; Damage sound (pulse channel — harsh buzz)
    lda #%00111100          ; Duty 12.5%, volume 12
    sta SQ1_VOL
    lda #%00000000          ; No sweep
    sta SQ1_SWEEP
    lda #$80                ; Timer low — low pitch
    sta SQ1_LO
    lda #$01                ; Timer high=1, length counter
    sta SQ1_HI

@no_hazard:
