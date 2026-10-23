; Physical Space/T samples, no character-buffer consumption or autorepeat.
; STATE+3 previous held, +8 rising edges, +9 current held. A/X/Y/P clobbered.
sample_keys:
    lda #0
    sta STATE+9
    lda #129
    ldx #$9d                 ; INKEY(-99): Space
    ldy #$ff
    jsr $fff4
    txa
    beq space_up
    inc STATE+9
space_up:
    lda #129
    ldx #$dc                 ; INKEY(-36): T
    ldy #$ff
    jsr $fff4
    txa
    beq t_up
    lda STATE+9
    ora #2
    sta STATE+9
t_up:
    lda STATE+3
    eor #255
    and STATE+9
    sta STATE+8
    lda STATE+9
    sta STATE+3
    rts
