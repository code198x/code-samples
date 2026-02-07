; -----------------------------------------------------------------------------
; take_damage: Deduct a life and handle the result
; Effect: Decrements lives. If lives remain, resets player and plays sound.
;         If no lives remain, sets game_over flag and hides the player.
; -----------------------------------------------------------------------------
take_damage:
    lda lives
    beq @done               ; Already dead — ignore

    dec lives
    bne @still_alive

    ; --- Game over ---
    lda #1
    sta game_over
    lda #$EF
    sta player_y            ; Will propagate to OAM, hiding sprite
    rts

@still_alive:
    ; --- Reset player position ---
    lda #PLAYER_X
    sta player_x
    lda #PLAYER_Y
    sta player_y
    lda #0
    sta vel_y
    lda #1
    sta on_ground

    ; --- Damage sound (pulse channel — harsh buzz) ---
    lda #%00111100          ; Duty 12.5%, volume 12
    sta SQ1_VOL
    lda #%00000000          ; No sweep
    sta SQ1_SWEEP
    lda #$80                ; Timer low — low pitch
    sta SQ1_LO
    lda #$01                ; Timer high=1, length counter
    sta SQ1_HI

@done:
    rts
