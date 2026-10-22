; Caller defines TURN (four writable bytes) and ACCEPT_KEY.
; Binary arithmetic required: CLD before use. A/P clobbered; X/Y preserved.
init_turn:
    sta TURN
    lda #1
    sta TURN+1
    lda #0
    sta TURN+2
    sta TURN+3
    rts
accept_command:
    sta TURN+3
    lda #0
    sta TURN+2
    lda TURN+3
    cmp #ACCEPT_KEY
    bne command_done
    clc
    lda TURN
    adc TURN+1
    sta TURN
    lda #1
    sta TURN+2
command_done:
    rts
