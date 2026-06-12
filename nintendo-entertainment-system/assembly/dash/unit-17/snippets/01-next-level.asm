; -----------------------------------------------------------------------------
; next_level — every coin home: the world resets, faster
;   Three caps, three jobs: the level COUNTER never stops, the table INDEX
;   clamps at the last row, and the HUD DIGIT (in the NMI) shows 9 forever
;   after. The player's number tells the truth; the physics admits it ran
;   out of new ideas.
; -----------------------------------------------------------------------------
next_level:
    inc level
    lda #3
    sta coins_left
    jsr place_coins

    ; A new field starts at the gate — the runner returns to the start.
    ; (Leave them where they stand and the respawned coin under their
    ; feet collects itself on the next frame. Every reset, every plane.)
    lda #PLAYER_X
    sta player_x
    lda #PLAYER_Y
    sta player_y
    lda #0
    sta vel_y
    sta anim_timer
    sta anim_frame
    lda #1
    sta on_ground

    lda #255
    sta obstacle_x

    ldx level               ; table index = level - 1, clamped
    dex
    cpx #LEVEL_TOP
    bcc @speed_ok
    ldx #LEVEL_TOP
@speed_ok:
    lda level_speed_tbl, x
    sta obstacle_speed

    ldx #<fanfare_phrase    ; say so
    ldy #>fanfare_phrase
    jsr start_phrase
    rts
