    ; --- Title: blink PRESS START (VRAM writes belong to the NMI) ---
    lda game_state
    cmp #STATE_TITLE
    bne @not_title

    bit PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$0A
    sta PPUADDR
    lda blink_timer
    and #%00100000          ; 32 frames on, 32 off
    bne @blink_off
    ldx #0
@blink_text:
    lda press_text, x
    sta PPUDATA
    inx
    cpx #11
    bne @blink_text
    jmp @skip_hud
@blink_off:
    lda #0
    ldx #0
@blink_blank:
    sta PPUDATA
    inx
    cpx #11
    bne @blink_blank
    jmp @skip_hud
